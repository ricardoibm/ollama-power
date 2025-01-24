
#### **Prerequisites**

1.  **Infrastructure**:
    
    -   The virtual machine must be provisioned using the included Terraform script.
    -   Ensure the virtual machine is running CentOS 9 and has internet access.
2.  **Local Configuration**:
    
    -   Install Ansible (v2.10 or later).
    -   Configure the `inventory.ini` file with the IP and credentials of your IBM Power10 host.
    -   Add your SSH key to the `inventory.ini` file:
        `[ibm_power]`
        `<VM_IP> ansible_user=<USER> ansible_ssh_private_key_file=<PATH_TO_PRIVATE_KEY>` 
        
3.  **Permissions**:
    
    -   Ensure the user configured in Ansible has superuser (`sudo`) privileges.

----------

#### **How to Use**

1.  **Clone the Project**:
    
  
    
    `git clone https://github.com/ricardoibm/ollama-power.git` 
    
2.  **Create the Infrastructure**: Navigate to the `terraform` directory and execute the script:

    `terraform init`
   ` terraform apply` 
    
3.  **Run Playbooks**:
    
    -   **Install Docker and deploy Ollama**:
           
        `ansible-playbook -i inventory.ini playbooks/install_docker_and_ollama.yml` 
        
    -   **Deploy Open-WebUI and verify service**:

        `ansible-playbook -i inventory.ini playbooks/run_open_webui_container_with_check.yml` 
        

----------

#### **Considerations**

-   **Ports**:
    
    -   The `ollama` container uses port `11434`.
    -   The `open-webui` container exposes port `443` to the host.
    -   Ensure these ports are open in the virtual machine’s firewall.
-   **Required Modifications**:
    
    -   If you change credentials, IP, or SSH key path, update the `inventory.ini` file.
    -   You can modify mapped ports, mounted volumes, or container parameters directly in the playbooks.
-   **Wait Time**:
    
    -   The playbook for `open-webui` includes a port 443 check. If the wait time (`timeout`) is insufficient due to slow container startup, you can increase the value in the `wait_for` task.

----------

#### **Warnings**

-   **Security**:
    
    -   SSH keys should not be shared publicly. Keep your inventory and sensitive information private.
    -   Review the automatic restart parameter (`--restart always`) in the containers if this behavior is not desired.
-   **Resource Consumption**:
    
    -   Ensure the virtual machine has sufficient resources (CPU, RAM, storage) to run Docker and the containers.

----------

#### **License**

This project is licensed under the MIT License. Feel free to use, modify, and share this work.