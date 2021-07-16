# README

This is the repository for the [Westman Naturalists website](https://westman-naturalists.github.io)


## Update Events

- Go to the Westman Naturalists Events Google Sheet and add the event specifics as a new row
  - The `Description` should be formatted with Markdown, for example:
    - `**Hello**` would be bold **Hello**
    - `*Hello*` would be italics *Hello*
    - `[Sign up](https://link)` would be linked text like [Sign up](https://link)
    - Check out the events already there and how they look on the website
    - If you're really gungho, check out this Markdown cheat sheet: https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet. 
  - Separate paragraphs with a blank line (Use Ctrl-Enter to make new lines)

- Update website events
  - Option 1: Wait, the website automatically updates once per day
  - Option 2: Force an update by going to the [`render_site` 'Actions'](https://github.com/westman-naturalists/westman-naturalists.github.io/actions/workflows/render_site.yaml), and clicking on the "Run workflow" drop-down button, then the green "Run workflow" button. 

- Check on the status of the website update
  - Go to the [`render_site` 'Actions'](https://github.com/westman-naturalists/westman-naturalists.github.io/actions/workflows/render_site.yaml).
  - Each website update is listed (as `render_site`) with when it happened to the right, and the status button to the left
    - Yellow swirling = Pending (ongoing)
    - Green check = Successful
    - Red X = Unsuccessful

- Check formating of your event on the [Events page](https://westman-naturalists.github.io/events.html)
    
- If there are any problems contact Steffi
