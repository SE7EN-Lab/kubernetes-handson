 - To identify the os details of Linux machine
 - vi commands
 - Install a specific version of package on Linux machine
     - ubuntu:
     ```
        # check the installed version & candidate version of the package
        apt-cache policy <package-name>
        # Install the specific version of the package
        apt-get install <pacakage-name>=<version>
    ```
 - Hold auto upgrade of a specific package-name
    -ubuntu
    ```
    apt-mark hold <package-name>
    ```