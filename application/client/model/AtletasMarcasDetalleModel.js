/**
 * Definicion del modelo del detalle de los marcas de un atleta
 * basicamente pruebas combinadas.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 04:46:52 -0500 (mar, 24 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_atletasmarcas_detalle",
    showPrompt: true,
    dataFormat: "json",
    fields: [
        {name: "atletas_resultados_id", foreignKey: "mdl_atletasmarcas.atletas_resultados_id"},
        {name: "pruebas_codigo", title: "Codigo"},
        {name: "pruebas_descripcion", title: "Prueba"},
        {name: "competencias_pruebas_fecha", title: "Fecha", type: 'date'},
        {name: "atletas_resultados_resultado", title: "Marca"},
        {name: "competencias_pruebas_viento", title: "Viento", type: 'double'},
        {name: "obs", title: 'Obs'},
        {name: "atletas_resultados_puntos", title: "Puntos", type: 'integer'},
        {name: "pruebas_detalle_orden", type: 'integer'}
    ],
    fetchDataURL: glb_dataUrl + 'atletasPruebasResultadosDetalleController?op=fetch&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"}
    ]
});