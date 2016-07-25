/**
 * Definicion del modelo para los carnets de los atletas.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-03-25 10:47:11 -0500 (mar, 25 mar 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_atletascarnets",
    showPrompt: true,
    dataFormat: "json",
    fields: [
        {name: "atletas_carnets_id", primaryKey: "true"},
        {name: "atletas_carnets_numero", title: "Numero", required: true},
        {name: "atletas_codigo", title: "Atleta", required: true, foreignKey: "mdl_atletas.atletas_codigo"},
        {name: "atletas_carnets_agno", title: "A&ntilde;o", required: true, type: 'integer'},
        {name: "atletas_carnets_fecha", title: "Fecha Emision", type: 'date', required: true},
        // virtual
        {name: "atletas_nombre_completo", title: "Atleta", required: false}
    ],
    fetchDataURL: glb_dataUrl + 'atletasCarnetsController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'atletasCarnetsController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'atletasCarnetsController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'atletasCarnetsController?op=del&libid=SmartClient',
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