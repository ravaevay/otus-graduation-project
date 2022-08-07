variable cloud_id {
    description = "Cloud ID"
}

variable folder_id {
    description = "Folder ID"
}

variable zone {
    description = "Zone ID"
    default = "ru-central1-a"
}

variable public_key_path {
    description = "Path to public key used for ssh access"
}

variable subnet_id {
    description = "Subnet ID"
}

variable image_id {
    description = "VM image ID"
}

variable service_account_key_file {
    description = "Path to service account file"
}