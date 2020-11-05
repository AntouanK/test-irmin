<script>
  let errors = [];
  const graphQlUrl = "//localhost/graphql/";

  // Example POST method implementation:
  async function postData(url = "", data = {}) {
    // Default options are marked with *
    const response = await fetch(url, {
      method: "POST", // *GET, POST, PUT, DELETE, etc.
      cache: "no-cache", // *default, no-cache, reload, force-cache, only-if-cached
      headers: { "Content-Type": "application/json" },
      redirect: "follow", // manual, *follow, error
      referrerPolicy: "no-referrer", // no-referrer, *no-referrer-when-downgrade, origin, origin-when-cross-origin, same-origin, strict-origin, strict-origin-when-cross-origin, unsafe-url
      body: JSON.stringify(data), // body data type must match "Content-Type" header
    });
    return response.json(); // parses JSON response into native JavaScript objects
  }

  const getAllCars = () => {
    const query = `{
      master {
        tree {
          list_contents_recursively {
            metadata
            key
            value {
              license
              year
              make
              license
              color
              owner
            }
          }
        }
      }
    }`.replace(/\n|\t/g, " ");

    return postData(`http:${graphQlUrl}`, { query });
  };

  const addNewCar = ({ make, model, year, license, color, owner }) => {
    errors = [];
    if (make.length < 3) {
      errors.push('"make" has to be at least 3 characters long');
    }
    if (model.length < 3) {
      errors.push('"model" has to be at least 3 characters long');
    }
    if (license.length < 3) {
      errors.push('"license" has to be at least 3 characters long');
    }
    if (owner.length < 3) {
      errors.push('"owner" has to be at least 3 characters long');
    }

    if (errors.length > 0) {
      return;
    }

    const query = `
	  mutation {
		set(
			key: "cars/example", 
			value: 
				{ owner: "${owner}"
				, color: "${color}"
				, model: "${model}"
				, make: "${make}"
				, year: ${year}
				, license: "${license}"
				}
			) {
				hash
			}
		}`.replace(/\n|\t/g, " ");

    return postData(`http:${graphQlUrl}`, { query });
  };

  $: existingCars = [];

  const refreshCars = () =>
    getAllCars().then((response) => {
      existingCars = response.data.master.tree.list_contents_recursively;
    });

  //------------------------------------------------------------- form
  $: formData = {
    make: "",
    model: "",
    year: 2020,
    license: "",
    color: "BLACK",
    owner: "",
  };

  const handleSubmit = () => {
    addNewCar(formData)
      .then((response) => {
        if (Array.isArray(response.errors)) {
          errors = response.errors;
        }
        console.log(response);
      })
      .catch((err) => {
        console.error(err);
        errors = [err.message];
      });
  };
</script>

<style>
</style>

<main>
  <link
    rel="stylesheet"
    href="https://cdn.jsdelivr.net/npm/bulma@0.9.1/css/bulma.min.css" />

  <section class="section">
    <div class="columns">
      <div class="column">
        <div>
          <button class="button" on:click={refreshCars}>get cars</button>
        </div>
        <existing-cars class="content">
          <pre
            class="pre">
            {JSON.stringify(existingCars, null, 2)}
          </pre>
        </existing-cars>
      </div>
      <div class="column">
        <new-car>
          <p>Add a new car</p>
          <form action="" class="form" on:submit|preventDefault={handleSubmit}>
            <label for="car-owner" class="label">
              <input
                id="car-owner"
                type="text"
                minlength="3"
                class="input"
                bind:value={formData.owner}
                placeholder="enter the owner's name" />
            </label>
            <label for="car-make" class="label">
              <input
                id="car-make"
                type="text"
                minlength="3"
                class="input"
                bind:value={formData.make}
                placeholder="car's make" />
            </label>
            <label for="car-model" class="label">
              <input
                id="car-model"
                type="text"
                minlength="3"
                class="input"
                bind:value={formData.model}
                placeholder="car's model" />
            </label>
            <label for="car-license" class="label">
              <input
                id="car-license"
                type="text"
                minlength="3"
                class="input"
                bind:value={formData.license}
                placeholder="car's license" />
            </label>
            <label for="car-color" class="label">
              <select
                id="car-color"
                type="select"
                class="input"
                bind:value={formData.color}>
                <option value="BLACK">Black</option>
                <option value="WHITE">White</option>
              </select>
            </label>
            <label for="car-year" class="label">
              <input
                id="car-year"
                type="number"
                class="input"
                bind:value={formData.year}
                placeholder="car's year" />
            </label>
            <input type="submit" class="input" />
          </form>
          <errors class="content has-text-danger">
            {errors.length > 0 ? JSON.stringify(errors, null, 2) : ''}
          </errors>
        </new-car>
      </div>
    </div>
  </section>
</main>
