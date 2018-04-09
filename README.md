# Powershell-utils
Powershell-utils i use for common tasks

**CreateWebsite.ps1**  
I use this script to create new IIS websites. It could easily be extended with more settins and parameters when needed.  
The script do a lot of things that suits me, and my needs:
- Creates a application pool with the given name
- Sets an identity using a windows accound or appPool identity
- Sets Idle timeout to 0
- Sets desired .NET version
- Sets a recycle time for the pool
- Create a folder with the same name as tha pool
- Sets two bindings
  - The first binding is on port 80 and is the same as the name of the pool.
  - The second binding is on a portnumber 17000 + the id of site, eg 17001 for the first site.
