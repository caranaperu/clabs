/**
 * Definicion del modelo para las pruebas que ha realizado alguna vez un determinado
 * atleta. Solo se requiere fetch ya que es ara efectos de presentacion.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 02:39:31 -0500 (mar, 24 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_atletas_pruebas",
    showPrompt: true,
    dataFormat: "json",
    fields: [
        {name: "apppruebas_codigo"},
        {name: "apppruebas_descripcion", title: 'Pruebas'}
    ],
    fetchDataURL: glb_dataUrl + 'atletasPruebasResultadosController?op=fetch&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"}
    ]
});