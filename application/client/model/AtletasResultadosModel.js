/**
 * Definicion del modelo los resultados de un atleta
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 02:39:31 -0500 (mar, 24 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_atletas_resultados",
    showPrompt: true,
    dataFormat: "json",
    noNullUpdates: true,
    sendExtraFields: false,
    dropExtraFields: true,
    fields: [
        {
            name: "atletas_resultados_id",
            primaryKey: "true",
            type: 'integer',
            required: true
        },
        {
            name: "atletas_codigo",
            title: 'Atleta',
            required: true
        },
        {
            name: "atletas_resultados_resultado",
            title: 'Marca',
            required: true
        },
        {
            name: "atletas_resultados_puntos",
            title: "Puntos",
            type: 'integer',
            required: true,
            validators: [{
                type: "lengthRange",
                max: 4
            },
                {
                    type: 'integerRange',
                    min: 0,
                    max: 1400
                }]
        },
        {
            name: "atletas_resultados_puesto",
            title: "Puesto",
            type: 'integer',
            required: true,
            validators: [{
                type: 'integerRange',
                min: 0,
                max: 100
            }]
        },
        {
            name: "atletas_resultados_viento",
            title: "Viento",
            type: 'double',
            validators: [{
                type: "lengthRange",
                min: 1
            },
                {
                    type: 'floatRange',
                    min: -20.00,
                    max: 20.00
                }]
        },
        {
            name: "competencias_pruebas_id",
            type: 'integer'
        },
        {
            name: "postas_id",
            title: 'Posta',
            type: 'integer',
            required: true,
            foreignKey: "mdl_postas.postas_id",
            nullReplacementValue: null
        },
        {
            name: "versionId",
            type: 'integer',
            nullReplacementValue: null
        },
        // Virtuales producto de un join
        // Solo para efectos de GUI no se grabaran
        {
            name: "atletas_nombre_completo",
            title: 'Atleta'
        },
        {
            name: "postas_atletas",
            title: 'Atletas'
        }
    ],
    /**
     * Normalizador de valores booleanos ya que el backend pude devolver de diversas formas
     * segun la base de datos.
     */
    _getBooleanFieldValue: function (value) {
        //  console.log(value);
        if (value !== 't' && value !== 'T' && value !== 'Y' && value !== 'y' && value !== 'TRUE' && value !== 'true' && value !== true) {
            return false;
        } else {
            return true;
        }

    },
    fetchDataURL: glb_dataUrl + 'atletasResultadosController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'atletasResultadosController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'atletasResultadosController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'atletasResultadosController?op=del&libid=SmartClient',
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