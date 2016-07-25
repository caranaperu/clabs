/**
 * Definicion del modelo la relacion de entrenadores / Atletas.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-03-25 11:33:12 -0500 (mar, 25 mar 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_entrenadoresatletas",
    showPrompt: true,
    dataFormat: "json",
    fields: [
        {name: "entrenadoresatletas_id", primaryKey: "true"},
        {name: "entrenadores_codigo", required: true, hidden: true, },
        {name: "atletas_codigo", required: true, hidden: true, foreignKey: "mdl_atletas.atletas_codigo"},
        {name: "atletas_nombre_completo"},
        {name: "entrenadoresatletas_desde", type: 'date', required: true},
        {name: "entrenadoresatletas_hasta", type: 'date'}
    ],
    fetchDataURL: glb_dataUrl + 'entrenadoresAtletasController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'entrenadoresAtletasController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'entrenadoresAtletasController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'entrenadoresAtletasController?op=del&libid=SmartClient',
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