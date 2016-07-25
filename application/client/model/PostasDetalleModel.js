/**
 * Definicion del modelo los componentes de una posta
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 04:42:57 -0500 (mar, 24 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_postasdetalle",
    showPrompt: true,
    dataFormat: "json",
    fields: [
        {
            name: "postas_detalle_id",
            primaryKey: "true",
            type: 'integer',
            required: true
        },
        {
            name: "postas_id",
            foreignKey: "mdl_postas.postas_id",
            type: 'integer',
            required: true
        },
        {
            name: "atletas_codigo",
            foreignKey: "mdl_atletas.atletas_codigo",
            required: true
        }
    ],
    fetchDataURL: glb_dataUrl + 'postasDetalleController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'postasDetalleController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'postasDetalleController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'postasDetalleController?op=del&libid=SmartClient',
    operationBindings: [
        {
            operationType: "fetch",
            dataProtocol: "postParams"
        },
        {
            operationType: "add",
            dataProtocol: "postParams"
        },
        {
            operationType: "update",
            dataProtocol: "postParams"
        },
        {
            operationType: "remove",
            dataProtocol: "postParams"
        }
    ],
    /**
     * Dado que cuando se esita en grilla no se pasan todos los valores
     * y estos se conservan en _oldValues , copiamos todos los
     * de oldValues a la data a transmitir siempre que oldvalues este
     * este definida , lo cual sucede solo para el update.
     */
    transformRequest: function (dsRequest) {
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