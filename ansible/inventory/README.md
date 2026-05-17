                                                                                                  
  ┌───────────────────┬─────────┬─────────────────────────────────────────────────┐               
  │  1Password Item   │  Vault  │         op:// reference used in aap.ini         │               
  ├───────────────────┼─────────┼─────────────────────────────────────────────────┤
  │ AAP Gateway Admin │ d3HLPRV │ admin_password                                  │               
  ├───────────────────┼─────────┼─────────────────────────────────────────────────┤             
  │ AAP Hub Admin     │ d3HLPRV │ automationhub_admin_password                    │             
  ├───────────────────┼─────────┼─────────────────────────────────────────────────┤             
  │ AAP Controller DB │ d3HLPRV │ pg_password (user: awx)                         │
  ├───────────────────┼─────────┼─────────────────────────────────────────────────┤
  │ AAP Hub DB        │ d3HLPRV │ automationhub_pg_password (user: automationhub) │
  └───────────────────┴─────────┴─────────────────────────────────────────────────┘

  DB passwords use alphanumeric-only (32 chars) to avoid quoting issues with PostgreSQL connection
   strings; admin passwords include symbols. To render the file before running setup.sh, use op
  inject -i aap.ini -o aap-rendered.ini.