open Lwt.Infix

module Car = struct
  type color = Black | White | Other of string [@@deriving irmin]

  type t = {
    license : string;
    year : int;
    make_and_model : string * string;
    color : color;
    owner : string;
  }
  [@@deriving irmin]

  let merge = Irmin.Merge.(option (idempotent t))
end

module Store = Irmin_unix.Git.FS.KV (Car)

module Custom_types = struct
  module Defaults = Irmin_graphql.Server.Default_types (Store)
  module Key = Defaults.Key
  module Metadata = Defaults.Metadata
  module Hash = Defaults.Hash
  module Branch = Defaults.Branch

  module Contents = struct
    open Graphql_lwt

    let color_values =
      Schema.
        [
          enum_value "BLACK" ~value:Car.Black;
          enum_value "WHITE" ~value:Car.White;
        ]

    let schema_typ =
      Schema.(
        obj "Car" ~fields:(fun _ ->
            [
              field "license" ~typ:(non_null string) ~args:[]
                ~resolve:(fun _ car -> car.Car.license);
              field "year" ~typ:(non_null int) ~args:[]
                ~resolve:(fun _ car -> car.Car.year);
              field "make" ~typ:(non_null string) ~args:[]
                ~resolve:(fun _ car -> fst car.Car.make_and_model);
              field "model" ~typ:(non_null string) ~args:[]
                ~resolve:(fun _ car -> snd car.Car.make_and_model);
              field "color" ~typ:(non_null string) ~args:[]
                ~resolve:(fun _ car -> car.Car.license);
              field "owner" ~typ:(non_null string) ~args:[]
                ~resolve:(fun _ car -> car.Car.owner);
            ]))

    let color = Schema.Arg.enum "Color" ~values:color_values

    let arg_typ =
      Schema.Arg.(
        obj "CarInput"
          ~fields:
            [
              arg "license" ~typ:(non_null string);
              arg "year" ~typ:(non_null int);
              arg "make" ~typ:(non_null string);
              arg "model" ~typ:(non_null string);
              arg "color" ~typ:(non_null color);
              arg "owner" ~typ:(non_null string);
            ]
          ~coerce:(fun license year make model color owner ->
            {
              Car.license;
              year = year;
              make_and_model = (make, model);
              color;
              owner;
            }))
  end
end

module Remote = struct
  let remote = Some Store.remote
end

module Server =
  Irmin_unix.Graphql.Server.Make_ext (Store) (Remote) (Custom_types)

let main () =
  Config.init ();
  let config = Irmin_git.config Config.root in
  Store.Repo.v config >>= fun repo ->
  let server = Server.v repo in
  let src = "0.0.0.0" in
  let port = 9876 in
  Conduit_lwt_unix.init ~src () >>= fun ctx ->
  let ctx = Cohttp_lwt_unix.Net.init ~ctx () in
  let on_exn exn = Printf.printf "on_exn: %s" (Printexc.to_string exn) in
  Printf.printf "Visit GraphiQL @ http://%s:%d/graphql\n%!" src port;
  Cohttp_lwt_unix.Server.create ~on_exn ~ctx ~mode:(`TCP (`Port port)) server

let reporter ppf =
  let report src level ~over k msgf =
    let k _ =
      over () ;
      k () in
    let with_metadata header _tags k ppf fmt =
      Format.kfprintf k ppf
        ("%a[%a]: " ^^ fmt ^^ "\n%!")
        Logs_fmt.pp_header (level, header)
        Fmt.(styled `Magenta string)
        (Logs.Src.name src) in
    msgf @@ fun ?header ?tags fmt -> with_metadata header tags k ppf fmt in
  { Logs.report }

let () = Logs.set_reporter (reporter Fmt.stderr)
let () = Logs.set_level ~all:true (Some Logs.Debug)

let () = Lwt_main.run (main ())
