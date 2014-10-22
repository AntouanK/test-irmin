(*
 * Copyright (c) 2013-2014 Thomas Gazagnaire <thomas@gazagnaire.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

let is_valid_utf8 str =
  try
    Uutf.String.fold_utf_8 (fun _ _ -> function
        | `Malformed _ -> raise (Failure "utf8")
        | _ -> ()
      ) () str;
    true
  with Failure "utf8" -> false

let encode_string str =
  if is_valid_utf8 str
  then Ezjsonm.string str
  else `O [ "hex", Ezjsonm.string (Hex.encode str) ]

let decode_string = function
  | `String str               -> Some str
  | `O [ "hex", `String str ] -> Some (Hex.decode str)
  | j                         -> None

let decode_string_exn j =
  match decode_string j with
  | Some s -> s
  | None   ->
    failwith (
      Printf.sprintf "%s is not a valid UT8-encoded JSON string"
        (Ezjsonm.to_string j)
    )

let rec of_sexp = function
  | Sexplib.Type.Atom x -> encode_string x
  | Sexplib.Type.List l -> Ezjsonm.list of_sexp l

let rec to_sexp json =
  match decode_string json with
  | Some s -> Sexplib.Type.Atom s
  | None   ->
    match json with
    | `A l -> Sexplib.Type.List (List.map to_sexp l)
    | _    ->
      failwith (Printf.sprintf "Json.to_sexp: %s" (Ezjsonm.to_string json))
