/**
 * Definicion del modelo para los insumos.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_insumo",
    dataFormat: "json",
    showPrompt: true,
    fields: [
        {name: "insumo_codigo", title: "Codigo", primaryKey: "true", required: true},
        {name: "insumo_descripcion", title: "Descripcion", required: true,
            validators: [{type: "regexp", expression: glb_RE_onlyValidText}]
        },
        {name: "tcostos_codigo", title: "Tipo Costos", foreignKey: "mdl_tcostos.tcostos_codigo", required: true},
        {name: "tinsumo_codigo", title: "Tipo Insumo", foreignKey: "mdl_tinsumo.tinsumo_codigo", required: true},
        {name: "unidad_medida_codigo", title: 'Unidad Medida', foreignKey: "mdl_unidadmedida.unidad_medida_codigo", required: true},
        {
            name: "insumo_merma", title:'Merma',required: true,
            validators: [{type: 'floatRange', min: 0.0001, max: 100000.00}, {type: "floatPrecision", precision: 4}]
        },
        // campos join
        {name: "_tcostos_descripcion", title: "Tipo Costos"},
        {name: "_tinsumo_descripcion", title: "Tipo Insumo"},
        {name: "_unidad_medida_descripcion", title: "Unidad Medida"}
    ],
    fetchDataURL: glb_dataUrl + 'insumoController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'insumoController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'insumoController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'insumoController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});