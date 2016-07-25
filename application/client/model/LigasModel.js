/**
 * Definicion del modelo para las ligas federadas
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-02-18 11:40:30 -0500 (mar, 18 feb 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_ligas",
    showPrompt: true,
    dataFormat: "json",
    fields: [
        {name: "ligas_codigo", primaryKey: "true", required: true},
        {name: "ligas_descripcion", title: "Descripcion", required: true,
            validators: [{type: "regexp", expression: glb_RE_onlyValidText}]
        },
        {name: "ligas_persona_contacto", title: "Persona De Contacto", required: true, validators: [{type: "lengthRange", max: 150}]},
        {name: "ligas_direccion", title: "Direccion", required: true, validators: [{type: "lengthRange", max: 250}]},
        {name: "ligas_telefono_oficina", title: "Tlf.Oficina", mask: glb_MSK_phone, validators: [{type: "lengthRange", min: 7, max: 13}]},
        {name: "ligas_telefono_celular", title: "Tlf.Celular", mask: glb_MSK_phone, validators: [{type: "lengthRange", min: 9, max: 13}]},
        {name: "ligas_email", title: "E-Mail", validators: [{type: "lengthRange", max: 150}, {type: "regexp",
                    expression: glb_RE_email}]},
        {name: "ligas_web_url", title: "Pagina Web", validators: [{type: "regexp", expression: glb_RE_url}, {type: "lengthRange", max: 200}]}
    ],
    fetchDataURL: glb_dataUrl + 'ligasController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'ligasController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'ligasController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'ligasController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});