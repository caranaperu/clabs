/**
 * Definicion del modelo los pruebas/resultados de un atleta
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 04:44:25 -0500 (mar, 24 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_atletaspruebas_resultados_detalles",
    showPrompt: true,
    dataFormat: "json",
    noNullUpdates: true,
    sendExtraFields: false,
    dropExtraFields: true,
    fields: [
        {name: "atletas_resultados_id", primaryKey: "true", type: 'integer', required: true},
        {name: "atletas_codigo", title: 'Atleta', required: true},
        {name: "competencias_codigo", title: "Competencia", required: true},
        {name: "pruebas_codigo", title: "Prueba", required: true},
        {name: "competencias_pruebas_origen_combinada", type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_atletaspruebas_resultados_detalles._getBooleanFieldValue(v);
            }},
        {name: "competencias_pruebas_fecha", title: "Fecha", type: 'date', required: true},
        {name: "competencias_pruebas_viento", title: "Viento", type: 'double'},
        {name: "competencias_pruebas_tipo_serie"},
        {name: "competencias_pruebas_nro_serie", type: 'integer'},
        {name: "competencias_pruebas_anemometro", title: 'A', type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_atletaspruebas_resultados_detalles._getBooleanFieldValue(v);
            }, required: true},
        {name: "competencias_pruebas_material_reglamentario", title: 'I', type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_atletaspruebas_resultados_detalles._getBooleanFieldValue(v);
            }, required: true},
        {name: "competencias_pruebas_manual", title: 'M', type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_atletaspruebas_resultados_detalles._getBooleanFieldValue(v);
            }, required: true},
        {name: "competencias_pruebas_observaciones", title: "Observaciones", validators: [{type: "lengthRange", max: 250}]},
        {name: "atletas_resultados_resultado", title: 'Marca', required: true},
        {name: "atletas_resultados_puntos", title: "Puntos", type: 'integer', required: true,
            validators: [{type: "lengthRange", max: 4}, {type: 'integerRange', min: 0, max: 1400}]},
        {name: "atletas_resultados_puesto", title: "Puesto", type: 'integer'},
        {name: "competencias_pruebas_id", type: 'integer', required: true},
        {name: "competencias_pruebas_origen_id", type: 'integer', required: true},
        {name: "versionId", type: 'integer', nullReplacementValue: null},
        // Virtuales producto de un join
        // Solo para efectos de GUI no se grabaran
        {name: "pruebas_descripcion", title: 'Prueba'},
        {name: "apppruebas_verifica_viento", type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_atletaspruebas_resultados_detalles._getBooleanFieldValue(v);
            }},
        {name: "unidad_medida_tipo"},
        {name: "unidad_medida_regex_e"},
        {name: "unidad_medida_regex_m"}
    ],
    /**
     * @private
     * Lista de campos que   no deben ser proesados por transforRequest asi sean null o undefined
     * @property {array} lista de campos con excepcion.
     */
    _noTransformFields: ['competencias_pruebas_viento','atletas_resultados_puesto'],
    /**
     * Normalizador de valores booleanos ya que el backend pude devolver de diversas formas
     * segun la base de datos.
     */
    _getBooleanFieldValue: function(value) {
        //  console.log(value);
        if (value !== 't' && value !== 'T' && value !== 'Y' && value !== 'y' && value !== 'TRUE' && value !== 'true' && value !== true) {
            return false;
        } else {
            return true;
        }

    },
    fetchDataURL: glb_dataUrl + 'atletasPruebasResultadosDetalleController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'atletasPruebasResultadosDetalleController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'atletasPruebasResultadosDetalleController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'atletasPruebasResultadosDetalleController?op=del&libid=SmartClient',
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
                if (this._noTransformFields.indexOf(fieldName) === -1) {
                    if (data[fieldName] === undefined) {
                        data[fieldName] = dsRequest.oldValues[fieldName];
                    }
                    else if (data[fieldName] === null) {
                        data[fieldName] = '';
                    }
                }
            }
            return data;
        } else {
            return data;
        }
    }
});