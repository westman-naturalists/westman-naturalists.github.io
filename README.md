# README

This is the repository for the [Westman Naturalists website](https://westman-naturalists.github.io)


## Update Events

- Go to the Westman Naturalists Events Google Sheet and add the event specifics as a new row
  - Title
  - Date
  - Time
  - Location
  - Description (in markdown format)

- Update website events
  - Option 1: Wait, the website automatically updates once per day
  - Option 2: Force an update by going to the [`render_site` 'Actions'](https://github.com/westman-naturalists/westman-naturalists.github.io/actions/workflows/render_site.yaml), and clicking on the "Run workflow" drop-down button, then the green "Run workflow" button. 

- Check on the status of the website update
  - Go to the [`render_site` 'Actions'](https://github.com/westman-naturalists/westman-naturalists.github.io/actions/workflows/render_site.yaml).
  - Each website update is listed (as `render_site`) with when it happened to the right, and the status button to the left
    - Yellow swirling = Pending (ongoing)
    - Green check = Successful
    - Red X = Unsuccessful
    
- If there are any problems contact Steffi
