import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from pathlib import Path

rng = np.random.default_rng(42)

# ---------- Catálogos ----------
n_products = 60
categories = ["Lácteos", "Bebidas", "Snacks", "Abarrotes", "Congelados", "Limpieza"]
brands = ["MarcaA", "MarcaB", "MarcaC", "MarcaD", "MarcaE"]

products = pd.DataFrame({"codigo_producto": [f"P{str(i).zfill(4)}" for i in range(1, n_products+1)]})
products["categoria"] = rng.choice(categories, size=n_products, replace=True)
products["marca"] = rng.choice(brands, size=n_products, replace=True)
products["nombre_producto"] = products.apply(lambda r: f"{r['categoria']} {r['marca']} {r.name%15+1}", axis=1)

n_stores = 10
regions = ["Norte", "Centro", "Sur"]
cities_by_region = {
    "Norte": ["Monterrey", "Saltillo", "Torreón"],
    "Centro": ["CDMX", "Puebla", "Querétaro"],
    "Sur": ["Mérida", "Tuxtla", "Oaxaca"],
}
stores = pd.DataFrame({"codigo_tienda": [f"T{str(i).zfill(3)}" for i in range(1, n_stores+1)]})
stores["region"] = rng.choice(regions, size=n_stores, replace=True)
stores["ciudad"] = stores["region"].map(lambda r: rng.choice(cities_by_region[r]))
stores["nombre_tienda"] = stores.apply(lambda r: f"Tienda {r['ciudad']} #{int(r.name)+1}", axis=1)

channels = pd.DataFrame({"canal": ["Mayorista", "Minorista", "Ecommerce", "Institucional"]})

n_clients = 200
segments = ["Oro", "Plata", "Bronce"]
all_cities = sum(cities_by_region.values(), [])

clients = pd.DataFrame({"codigo_cliente": [f"C{str(i).zfill(5)}" for i in range(1, n_clients+1)]})
clients["nombre_cliente"] = clients["codigo_cliente"].map(lambda c: f"Cliente {c}")
clients["ciudad_cliente"] = rng.choice(all_cities, size=n_clients, replace=True)
clients["segmento"] = rng.choice(segments, size=n_clients, replace=True)

# ---------- Ventas detalle (más granular) ----------
start = datetime(2025, 9, 1)
days = 120

date_times = []
for d in rng.integers(0, days, size=1200):
    date_times.append(start + timedelta(days=int(d), hours=int(rng.integers(8, 21)), minutes=int(rng.integers(0, 60))))

n_tickets = 800
ticket_ids = [f"TK{str(i).zfill(6)}" for i in range(1, n_tickets+1)]
ticket_times = rng.choice(pd.to_datetime(date_times), size=n_tickets, replace=False)

cat_mult = {"Lácteos":1.0, "Bebidas":1.1, "Snacks":0.9, "Abarrotes":1.0, "Congelados":1.3, "Limpieza":1.2}

lines = []
for tk, ttime in zip(ticket_ids, ticket_times):
    n_lines = int(rng.integers(1, 6))
    prod_idxs = rng.choice(products.index, size=n_lines, replace=False)
    store_idx = int(rng.integers(0, n_stores))
    client_idx = int(rng.integers(0, n_clients))
    canal = channels.loc[int(rng.integers(0, len(channels))), "canal"]

    for ln, pidx in enumerate(prod_idxs, start=1):
        qty = int(rng.integers(1, 9))
        base_price = float(rng.uniform(8, 220))
        cat = products.loc[pidx, "categoria"]
        price = round(base_price * cat_mult[cat], 2)

        bruto = round(qty * price, 2)
        disc_rate = float(rng.choice([0, 0.05, 0.10, 0.15, 0.20], p=[0.55, 0.18, 0.13, 0.09, 0.05]))
        if canal in ["Ecommerce", "Minorista"]:
            disc_rate = min(0.25, disc_rate + float(rng.choice([0, 0.05], p=[0.7, 0.3])))

        descuento = round(bruto * disc_rate, 2)
        neto = round(bruto - descuento, 2)

        lines.append({
            "fecha_hora": pd.Timestamp(ttime),
            "numero_ticket": tk,
            "numero_linea": ln,
            "codigo_producto": products.loc[pidx, "codigo_producto"],
            "codigo_tienda": stores.loc[store_idx, "codigo_tienda"],
            "codigo_cliente": clients.loc[client_idx, "codigo_cliente"],
            "canal": canal,
            "cantidad_vendida": qty,
            "precio_unitario": price,
            "importe_bruto": bruto,
            "descuento_linea": descuento,
            "importe_neto": neto,

            # (extracto desnormalizado)
            "nombre_producto": products.loc[pidx, "nombre_producto"],
            "categoria": products.loc[pidx, "categoria"],
            "marca": products.loc[pidx, "marca"],
            "nombre_tienda": stores.loc[store_idx, "nombre_tienda"],
            "ciudad_tienda": stores.loc[store_idx, "ciudad"],
            "region_tienda": stores.loc[store_idx, "region"],
            "nombre_cliente": clients.loc[client_idx, "nombre_cliente"],
            "segmento_cliente": clients.loc[client_idx, "segmento"],
            "ciudad_cliente": clients.loc[client_idx, "ciudad_cliente"],
        })

ventas_detalle_raw = pd.DataFrame(lines).sort_values(["fecha_hora","numero_ticket","numero_linea"]).reset_index(drop=True)

# ---------- Ventas diaria (menos granular) ----------
ventas_detalle_raw["fecha"] = pd.to_datetime(ventas_detalle_raw["fecha_hora"]).dt.date
ventas_diaria_raw = (
    ventas_detalle_raw
    .groupby(["fecha","codigo_producto","codigo_tienda","canal"], as_index=False)
    .agg(
        cantidad_vendida=("cantidad_vendida","sum"),
        importe_bruto=("importe_bruto","sum"),
        descuento_total=("descuento_linea","sum"),
        importe_neto=("importe_neto","sum"),
    )
).merge(products, on="codigo_producto", how="left").merge(stores, on="codigo_tienda", how="left")

# ---------- Cambios de cliente (para SCD2) ----------
n_changes = 25
changed_clients = rng.choice(clients["codigo_cliente"], size=n_changes, replace=False)
change_rows = []
for c in changed_clients:
    orig = clients.loc[clients["codigo_cliente"]==c].iloc[0]
    eff = start + timedelta(days=int(rng.integers(20, 100)))
    new_segment = rng.choice([s for s in segments if s != orig["segmento"]])
    new_city = rng.choice([city for city in all_cities if city != orig["ciudad_cliente"]])

    change_rows.append({
        "codigo_cliente": c,
        "atributo_cambiado": "segmento",
        "valor_anterior": orig["segmento"],
        "valor_nuevo": new_segment,
        "fecha_inicio": eff.date(),
    })
    change_rows.append({
        "codigo_cliente": c,
        "atributo_cambiado": "ciudad_cliente",
        "valor_anterior": orig["ciudad_cliente"],
        "valor_nuevo": new_city,
        "fecha_inicio": (eff + timedelta(days=int(rng.integers(0,10)))).date(),
    })

clientes_cambios = pd.DataFrame(change_rows).sort_values(["codigo_cliente","fecha_inicio"]).reset_index(drop=True)

# ---------- Export a Excel ----------
out_dir = Path(".")
file_detalle = out_dir / "SGFood_HT2_VentasDetalle_Raw.xlsx"
file_diaria  = out_dir / "SGFood_HT2_VentasDiaria_Raw.xlsx"

with pd.ExcelWriter(file_detalle, engine="openpyxl") as writer:
    pd.DataFrame({
        "Hoja": ["VentasDetalle_Raw","Clientes_Cambios","Catalogo_Productos","Catalogo_Tiendas","Catalogo_Canales","Catalogo_Clientes"]
    }).to_excel(writer, sheet_name="README", index=False)

    ventas_detalle_raw.to_excel(writer, sheet_name="VentasDetalle_Raw", index=False)
    clientes_cambios.to_excel(writer, sheet_name="Clientes_Cambios", index=False)
    products.to_excel(writer, sheet_name="Catalogo_Productos", index=False)
    stores.to_excel(writer, sheet_name="Catalogo_Tiendas", index=False)
    channels.to_excel(writer, sheet_name="Catalogo_Canales", index=False)
    clients.to_excel(writer, sheet_name="Catalogo_Clientes", index=False)

with pd.ExcelWriter(file_diaria, engine="openpyxl") as writer:
    pd.DataFrame({"Hoja": ["VentasDiaria_Raw","Catalogo_Productos","Catalogo_Tiendas","Catalogo_Canales"]}).to_excel(writer, sheet_name="README", index=False)
    ventas_diaria_raw.to_excel(writer, sheet_name="VentasDiaria_Raw", index=False)
    products.to_excel(writer, sheet_name="Catalogo_Productos", index=False)
    stores.to_excel(writer, sheet_name="Catalogo_Tiendas", index=False)
    channels.to_excel(writer, sheet_name="Catalogo_Canales", index=False)

print("Listo:", file_detalle, file_diaria)
