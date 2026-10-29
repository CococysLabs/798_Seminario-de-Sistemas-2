import os
import re

import httpx
from fastapi import FastAPI, Form, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

app = FastAPI(title="Inscripción SS2", docs_url=None, redoc_url=None)
app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")
USERNAME = re.compile(r"^(?!-)[A-Za-z0-9-]{1,39}(?<!-)$")


@app.get("/health")
async def health():
    return {"status": "ok", "github_configured": bool(os.getenv("GITHUB_TOKEN"))}


@app.get("/", response_class=HTMLResponse)
async def form(request: Request):
    return templates.TemplateResponse(request, "index.html", {"message": None})


@app.post("/invite", response_class=HTMLResponse)
async def invite(request: Request, github_username: str = Form(...)):
    username = github_username.strip()
    if not USERNAME.fullmatch(username):
        return templates.TemplateResponse(request, "index.html", {"message": "Usuario no válido."}, status_code=400)
    token = os.getenv("GITHUB_TOKEN")
    if not token:
        return templates.TemplateResponse(request, "index.html", {"message": "La invitación aún no está habilitada."}, status_code=503)
    headers = {"Accept": "application/vnd.github+json", "Authorization": f"Bearer {token}", "X-GitHub-Api-Version": "2022-11-28"}
    async with httpx.AsyncClient(timeout=10) as client:
        user = await client.get(f"https://api.github.com/users/{username}", headers=headers)
        if user.status_code == 404:
            message, status = "Ese usuario no existe en GitHub.", 404
        elif user.is_error:
            message, status = "No fue posible consultar GitHub.", 502
        else:
            result = await client.post(f"https://api.github.com/orgs/{os.getenv('GITHUB_ORG', 'SS2-USAC')}/invitations", headers=headers, json={"invitee_id": user.json()["id"], "role": "direct_member"})
            if result.status_code == 201:
                message, status = "Invitación enviada. Revisa tus notificaciones de GitHub.", 200
            elif result.status_code == 422:
                message, status = "Ya eres miembro o tienes una invitación pendiente.", 200
            else:
                message, status = "GitHub rechazó la invitación. Contacta al docente.", 502
    return templates.TemplateResponse(request, "index.html", {"message": message}, status_code=status)
