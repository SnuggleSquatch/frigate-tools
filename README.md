# frigate-tools: frigate-export-ui

This script sets up a basic Apache server with PHP for the frigate-export-ui tool.

## Configuration Parameters

- **$SUB_DIR**: `"exportui"`  
  **Description:** Sets the subdirectory URL.  
  **Example:** `http://frigate.example.com/`_exportui_

- **$exportUrl**:  
  ```bash
  "http://localhost:5000/api/export/$camera/start/$startTimestamp/end/$endTimestamp"
  ```  
  **Description:** Defines the API endpoint for exporting data. Replace `localhost` and `5000` with the appropriate hostname and port for your use case.

- **Meta Refresh Tag**:  
  ```html
  <meta http-equiv="refresh" content="5;url=https://frigate.example.com/export">
  ```  
  **Description:** Automatically refreshes the page after a delay. The number following `content=` (in this case, `5`) determines the refresh delay in seconds, and the URL specifies the destination after the refresh.
