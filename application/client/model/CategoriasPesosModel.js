/**
 * Definicion del modelo para los paises
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 02:39:31 -0500 (mar, 24 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_categorias_pesos",
    dataFormat: "json",
    cacheAllData: true, // Son datos pequeños hay que evitar releer
    fields: [
        {name: "categorias_codigo", primaryKey: "true", required: true},
        {name: "categorias_descripcion", title: "Descripcion"},
        {name: "appcat_peso", type: 'integer'}
    ],

    fetchDataURL: glb_dataUrl + 'categoriasController?op=fetch&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"}
    ]
});