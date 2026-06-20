1. Install UV : powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
Check : uv --version
   2. init : uv init
       => pyproject.toml
          README.md
          .python-version
3. virtual environment : uv venv
4. active : .venv\Scripts\activate
5.  package install 
uv add customtkinter
uv add pydantic