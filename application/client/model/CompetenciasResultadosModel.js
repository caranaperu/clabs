/**
 * Definicion del modelo los resultado de una prueba en una determinada
 * competencia (para vista no edicion)
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 02:39:31 -0500 (mar, 24 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_competenciasresultados",
    showPrompt: true,
    dataFormat: "json",
    fields: [
        {name: "atletas_resultados_id"},
        {name: "atletas_codigo"},
        {
            name: "atletas_nombre_completo",
            title: 'Atleta'
        },
        {
            name: "postas_atletas",
            title: 'Posta/Atletas'
        },
        {
            name: "pruebas_codigo",
            title: "Prueba"
        },
        {
            name: "atletas_resultados_puesto",
            title: "Puesto",
            type: 'integer'
        },
        {
            name: "atletas_resultados_resultado",
            title: "Marca"
        },
        {
            name: "competencias_pruebas_viento",
            title: "Viento"
        },
        {
            name: "competencias_pruebas_fecha",
            title: "Fecha",
            type: 'date'
        },
        {
            name: "obs",
            title: "Obs"
        },
        {
            name: "serie",
            title: "Sr."
        },
        {
            name: "categorias_codigo",
            title: "Cat."
        },
        {
            name: "pruebas_record_hasta",
            title: "Rank"
        },
        {name: "pruebas_generica_codigo"},
        {
            name: "apppruebas_multiple",
            type: 'boolean',
            getFieldValue: function (r, v, f, fn) {
                return mdl_competenciasresultados._getBooleanFieldValue(v);
            }
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
    fetchDataURL: glb_dataUrl + 'competenciasPruebasController?op=fetch&libid=SmartClient',
    operationBindings: [
        {
            operationType: "fetch",
            dataProtocol: "postParams"
        }
    ],
    /**
     * Caso especial para generar el JSON de un advanced criteria para ser pasada como parte del
     * POST.
     */
    transformRequest: function (dsRequest) {
        var data = this.Super("transformRequest", arguments);
        // Si esxiste criteria y se define que proviene de un advanced filter y la operacion es fetch,
        // construimos un objeto JSON serializado como texto para que el lado servidor lo interprete correctamente.
        if (data.criteria && data._constructor == "AdvancedCriteria" && data._operationType == 'fetch') {
            var advFilter = {};
            advFilter.operator = data.operator;
            advFilter.criteria = data.criteria;

            // Borramos datos originales que no son necesario ya que  seran trasladados al objeto JSON
            delete data.operator;
            delete data.criteria;
            delete data._constructor;

            // Creamos el objeto json como string para pasarlo al rest
            // finalmente se coloca como data del request para que siga su proceso estandard.
            var jsonCriteria = isc.JSON.encode(advFilter, {prettyPrint: false});
            if (jsonCriteria) {
                data._acriteria = jsonCriteria;
            }
        }
        return data;
    }
});