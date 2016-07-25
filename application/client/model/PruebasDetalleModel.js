/**
 * Definicion del modelo la relacion de pruebas combinadas/pruebas
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-04-06 19:54:57 -0500 (dom, 06 abr 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_pruebasdetalle",
    dataFormat: "json",
    showPrompt: true,
    fields: [
        {name: "pruebas_detalle_id", primaryKey: "true", type: 'integer'},
        {name: "pruebas_codigo", required: true, hidden: true, },
        {name: "pruebas_detalle_prueba_codigo", required: true, foreignKey: "mdl_pruebas.pruebas_codigo"},
        {name: "pruebas_detalle_orden", required: true, type: 'integer'},
        {name: "pruebas_nombre_completo"}
    ],
    fetchDataURL: glb_dataUrl + 'pruebasDetalleController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'pruebasDetalleController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'pruebasDetalleController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'pruebasDetalleController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ],

    /**
     * Dado que cuando se esita en grilla no se pasan todos los valores
     * y estos se conservan en _oldValues , copiamos todos los
     * de oldValues a la data a transmitir siempre que oldvalues este
     * este definida , lo cual sucede solo para el update.
     */
    transformRequest: function(dsRequest) {
        var data = this.Super("transformRequest", arguments);
        if (dsRequest.operationType == 'add' || dsRequest.operationType == 'update') {
            //  var data = isc.addProperties({}, dsRequest.data);
            // Solo para los valores que se encuentran en oldValues de no existir
            // se deja como esta.
            for (var fieldName in dsRequest.oldValues) {
                if (data[fieldName] === undefined) {
                    data[fieldName] = dsRequest.oldValues[fieldName];
                }
                else if (data[fieldName] === null) {
                    data[fieldName] = '';
                }
            }
            return data;
        } else {
            return data;
        }
    }
});