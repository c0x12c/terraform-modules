# **Terraform Modules Registry**

This repository serves as a central registry for Terraform modules, efficiently managing them as Git submodules. It allows for seamless integration, version control, and tracking of different Terraform modules used across your infrastructure.

## **Working with Submodules**

### **Adding a New Module as a Submodule**

To integrate a new Terraform module repository as a submodule, follow the steps below:

1. **Add the Module as a Git Submodule**

   Run the following command to add the desired Terraform module repository:

   ```bash
   git submodule add <repository-url> [<path>]
   ```

   Example:

   ```bash
   git submodule add git@github.com:c0x12c/terraform-datadog-team.git terraform-datadog-team
   ```

2. **Commit the Changes**

   After adding the submodule, commit the changes to the repository:

   ```bash
   git add . 
   git commit -m "Add terraform-aws-vpc module as submodule"
   ```

3. **Submit a Pull Request**

   Create a pull request to integrate the new submodule into the registry.

### **Initializing Submodules (First-Time Clone)**

When cloning this repository for the first time, or when submodules have not been initialized, follow these steps:

1. **Clone the Repository with Submodules**
   Clone the repository using the `--recursive` flag to automatically initialize and update submodules:

   ```bash
   git clone --recursive git@github.com:c0x12c/terraform-modules-registry.git
   ```

2. **Initialize Submodules if Already Cloned**

   If you’ve cloned the repository without the `--recursive` flag, use the following command to initialize and update all submodules:

   ```bash
   git submodule update --init --recursive
   ```

### **Updating All Submodules**

To update all submodules to their latest versions, follow these steps:

1. **Update All Submodules**
   Run the following command to pull the latest changes for all submodules:

   ```bash
   git submodule update --remote --merge
   ```

2. **Commit the Updates**

   After updating the submodules, commit the changes to the repository:

   ```bash
   git commit -am "Update all submodules to the latest version"
   ```

## **Best Practices for Managing Submodules**

1. **Use Specific Tags or Commits for Submodule References**
   Always refer to submodules using specific tags or commit hashes in your Terraform configurations. This ensures consistency and avoids unintentional changes from the submodule.

2. **Document Module-Specific Requirements**
   Clearly document any specific prerequisites, dependencies, or configuration settings within the individual module’s repository to ensure proper usage.

3. **Test Changes Before Committing**
   Always test changes within a submodule repository before updating its reference in the registry to avoid breaking changes.

4. **Maintain a Consistent Directory Structure**
   Use a consistent naming convention and directory structure for all submodules (e.g., `modules/<provider>/<module-name>`). This enhances organization and readability within the registry.

## **Additional Git Submodule Commands**

### **Check Submodule Status**

To view the current status of all submodules, use:

```bash
git submodule status
```

### **Removing a Submodule**

To remove a submodule, follow the steps below:

1. **Delete the Submodule from the `.gitmodules` File**
   Open the `.gitmodules` file and remove the corresponding entry for the submodule.

2. **Stage the Changes to `.gitmodules`**
   After modifying the `.gitmodules` file, stage the changes:

   ```bash
   git add .gitmodules
   ```

3. **Delete the Submodule from `.git/config`**
   Edit the `.git/config` file and remove any reference to the submodule.

4. **Deinitialize the Submodule**
   Run the following command to deinitialize the submodule:

   ```bash
   git submodule deinit <path_to_submodule>
   ```

5. **Remove the Submodule from Git Index**
   Remove the submodule from Git’s index:

   ```bash
   git rm --cached <path_to_submodule>
   ```

6. **Delete the Submodule Files**
   Manually remove the submodule files:

   ```bash
   rm -rf <path_to_submodule>
   ```

7. **Commit the Removal Changes**

   Finally, commit the changes to reflect the removal of the submodule:

   ```bash
   git commit -am "Remove submodule <module-name>"
   ```

---

This updated version includes the new repository URL `git@github.com:c0x12c/terraform-modules-registry.git`. Let me know if you need any further adjustments!
