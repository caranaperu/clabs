/**
 * Definicion del modelo para los paises
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 04:49:49 -0500 (mar, 24 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_pruebas_clasificacion",
    dataFormat: "json",
    showPrompt: true,
    //  cacheAllData: true, // Es necesario en diversos lugares de diversas formas , hay que obligar a leeer
    fields: [
        {name: "pruebas_clasificacion_codigo", primaryKey: "true", required: true},
        {name: "pruebas_clasificacion_descripcion", title: "Descripcion", required: true},
        {name: "pruebas_tipo_codigo", required: true, foreignKey: "mdl_pruebas_tipo.pruebas_tipo_codigo"},
        {name: "unidad_medida_codigo", required: true, foreignKey: "mdl_unidadmedida.unidad_medida_codigo"},
        // Virtuales solo para presentacion o uso del GUI
        {name: "unidad_medida_regex_e"},
        {name: "unidad_medida_regex_m"}
    ],
    fetchDataURL: glb_dataUrl + 'pruebasClasificacionController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'pruebasClasificacionController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'pruebasClasificacionController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'pruebasClasificacionController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ],
    /**
     * Solo para hacerla sincronica.
     * POST.
     *
     * @TODO: Si se resuelve con el dataArrived del control eliminar esto.
     */
    transformRequest: function(dsRequest) {
        // dsRequest.blocking = true;
        return  this.Super("transformRequest", arguments);
    }
});