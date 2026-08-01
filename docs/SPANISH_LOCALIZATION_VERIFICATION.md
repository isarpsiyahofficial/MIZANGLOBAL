# MİZAN GLOBAL — Verificación de la localización al español

## Alcance

La localización al español se integra como tercer idioma completo después del turco y el inglés. No habilita todavía ningún idioma posterior de la lista global.

## Criterios lingüísticos

- Se utiliza un español internacional claro y natural, sin calcos innecesarios del turco ni del inglés.
- La terminología financiera se mantiene coherente: `importe`, `fecha de vencimiento`, `cuota`, `saldo pendiente`, `pago registrado` y `obligaciones de pago`.
- Las órdenes y validaciones usan tratamiento de segunda persona coherente.
- El singular y el plural se generan por separado: `Queda 1 día` / `Quedan 2 días`, `falta 1 registro` / `faltan 2 registros`.
- La confirmación destructiva exige exactamente `CONFIRMO` cuando el idioma activo es español.
- Los nombres, notas, bancos, entidades y tipos de deuda escritos por el usuario nunca se traducen.

## Formatos

- Fechas cortas: `31 jul 2026`.
- Mes y año: `julio de 2026`.
- Importes: `EUR 1.234.567,50`.
- Los códigos ISO de moneda permanecen legibles y no se sustituyen por símbolos ambiguos.

## Cuatro capas de verificación

1. **Paridad estática:** las 791 claves del español deben coincidir exactamente con las 791 claves del inglés.
2. **Revisión lingüística:** terminología financiera, tono, gramática, singular/plural y ausencia de fugas en turco o inglés.
3. **Pruebas funcionales:** interfaz, búsquedas, informes, PDF, notificaciones, copias de seguridad, datos del usuario y confirmaciones destructivas.
4. **Regresión y compilación:** análisis estático, pruebas completas, comparación visual y APK universal más APK por arquitectura.

La rama de producto no debe recibir esta localización hasta que las cuatro capas finalicen correctamente.
