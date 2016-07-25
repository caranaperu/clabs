/**
 * Definicion del modelo Para los entrenadores.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-02-11 18:50:24 -0500 (mar, 11 feb 2014) $
 * $Rev: 6 $
 */
isc.RestDataSource.create({
    ID: "mdl_entrenadores",
    showPrompt: true,
    dataFormat: "json",
    fields: [
        {name: "entrenadores_codigo", primaryKey: "true", title: "Codigo", required: true},
        {name: "entrenadores_ap_paterno", title: "Apellido Paterno", required: true, validators: [{type: "regexp", expression: glb_RE_onlyValidText}]},
        {name: "entrenadores_ap_materno", title: "Apellido Materno", required: true, validators: [{type: "regexp", expression: glb_RE_onlyValidText}]},
        {name: "entrenadores_nombres", title: "Nombres", required: true, validators: [{type: "regexp", expression: glb_RE_onlyValidText}]},
        {name: "entrenadores_nombre_completo", title: "Apellidos,Nombres", required: false, validators: [{type: "regexp", expression: glb_RE_onlyValidTextWithComma}]},
        {name: "entrenadores_nivel_codigo", title: "Nivel", required: true, foreignKey: "mdl_entrenadores_nivel.entrenadores_nivel_codigo"}
    ],
    fetchDataURL: glb_dataUrl + 'entrenadoresController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'entrenadoresController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'entrenadoresController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'entrenadoresController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams", skipRowCount: true},
        {operationType: "remove", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"}
    ]
});