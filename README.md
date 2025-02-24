# frigate-tools: frigate-export-ui

This script sets up a basic Apache server with PHP for the frigate-export-ui tool.

## Configuration Parameters

- **$SUB_DIR**: `"exportui"` -OR- `"diff_sub_dir"`\
  **Description:** Sets the subdirectory URL.  
  **Example:** `http://frigate.example.com/exportui` -OR- `http://frigate.example.com/diff_sub_dir`

- **$exportUrl**:  
  ```bash
  "http://localhost:5000/api/export/$camera/start/$startTimestamp/end/$endTimestamp"
  ```  
  **Description:** Defines the API endpoint for exporting data. Replace `localhost` and `5000` with the appropriate hostname and port for your use case.

- **Default Timezone**:  
  ```php
  date_default_timezone_set('America/Denver');
  ```  
  **Description:** Will need to be set to match the timezone of your frigate server, you will need to use a [valid timezone](https://manpages.ubuntu.com/manpages/focal/en/man3/DateTime::TimeZone::Catalog.3pm.html).

- **Meta Refresh Tag**:  
  ```html
  <meta http-equiv="refresh" content="5;url=https://frigate.example.com/export">
  ```  
  **Description:** Automatically refreshes the page after a delay. The number following `content=` (in this case, `5`) determines the refresh delay in seconds, and the URL specifies the destination after the refresh.
