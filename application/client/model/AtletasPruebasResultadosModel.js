/**
 * Definicion del modelo los resultados de un atleta enuna prueba x, esto es para el caso
 * del ingreso de los resultados a traves de los atletas no a traves de las competencias
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 04:43:58 -0500 (mar, 24 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_atletaspruebas_resultados",
    showPrompt: true,
    dataFormat: "json",
    noNullUpdates: true,
    sendExtraFields: false,
    dropExtraFields: true,
    fields: [
        {name: "atletas_resultados_id", primaryKey: "true", required: true, type: 'integer'},
        {name: "atletas_codigo", title: 'Atleta', foreignKey: "mdl_atletas.atletas_codigo", required: true},
        {name: "competencias_codigo", title: "Competencia", foreignKey: "mdl_competencias.competencias_codigo", required: true},
        {name: "pruebas_codigo", title: "Prueba", foreignKey: "mdl_pruebas.pruebas_codigo", required: true},
        {name: "competencias_pruebas_fecha", title: "Fecha", type: 'date', required: true},
        {name: "competencias_pruebas_viento", title: "Viento", type: 'double',getFieldValue: function(r, v, f, fn) {
                return mdl_atletaspruebas_resultados._getVientoFieldValue(v);}},
        {name: "competencias_pruebas_tipo_serie", title: "Tipo Serie",
            valueMap: {"HT": 'Hit', "SR": 'Serie', "SM": 'SemiFinal', "FI": 'Final', "SU": 'Unica'},
            required: true},
        {name: "competencias_pruebas_nro_serie", title: "Nro.Serie", type: 'integer',
            validators: [{type: "integerRange", min: 1, max: 20}],
            nullReplacementValue: null},
        {name: "competencias_pruebas_anemometro", title: 'Anemometro?', type: 'boolean', getFieldValue: function (r, v, f, fn) {
                return mdl_atletaspruebas_resultados._getBooleanFieldValue(v);
            }, required: true},
        {name: "competencias_pruebas_material_reglamentario", title: 'Material Regl.?', type: 'boolean', getFieldValue: function (r, v, f, fn) {
                return mdl_atletaspruebas_resultados._getBooleanFieldValue(v);
            }, required: true},
        {name: "competencias_pruebas_manual", title: 'Manual?', type: 'boolean', getFieldValue: function (r, v, f, fn) {
                return mdl_atletaspruebas_resultados._getBooleanFieldValue(v);
            }, required: true},
        /*    {name: "competencias_pruebas_origen_combinada", type: 'boolean', getFieldValue: function(r, v, f, fn) {
         return mdl_atletaspruebas_resultados._getBooleanFieldValue(v);
         }, required: true},*/
        {name: "competencias_pruebas_observaciones", title: "Observaciones", validators: [{type: "lengthRange", max: 250}]},
        {name: "atletas_resultados_resultado", title: 'Marca', required: true},
        {name: "atletas_resultados_puntos", title: "Puntos", type: 'integer'},
        {name: "atletas_resultados_puesto", title: "Puesto", type: 'integer'},
        {name: "versionId", type: 'integer', nullReplacementValue: null},
        // Virtuales producto de un join
        {name: "ciudades_altura", title: 'Altura?', type: 'boolean', getFieldValue: function (r, v, f, fn) {
                return mdl_atletaspruebas_resultados._getBooleanFieldValue(v);
            }},
        {name: "obs", title: 'Obs.', type: 'boolean', getFieldValue: function (r, v, f, fn) {
                return mdl_atletaspruebas_resultados._getBooleanFieldValue(v);
            }},
        {name: "postas_id"},
        // Solo para efectos de GUI no se grabaran
        {name: "serie", title: 'Serie'},
        {name: "atletas_nombre_completo", title: 'Atleta'},
        {name: "pruebas_descripcion", title: 'Prueba'},
        {name: "competencias_descripcion", title: 'Competencia'},
        {name: "paises_descripcion", title: 'Pais'},
        {name: "ciudades_descripcion", title: ' Ciudad'},
        {name: "categorias_codigo", title: 'Categoria'},
        {name: "competencias_pruebas_id"},
        {name: "atletas_sexo"},
        {name: "apppruebas_multiple", type: 'boolean', getFieldValue: function (r, v, f, fn) {
                return mdl_atletaspruebas_resultados._getBooleanFieldValue(v);
            }}
    ],
    /**
     * Normalizador de valores para el viento ya que este puede ser null dependiendo de la prueba,
     * El problemas es que si llega con valor null a la forma este campo no es copiado a los values
     * de edicion al cargar inicialmente los valores. Se requiere que siempre tenga un valor aunque este sea imposible
     * lo cual indicara a la forma que en realidad es un valor nulo.
     * Se entiende que las pruebas que requieren viento traern un valor no null , de no ser asi los datos
     * en la bd seran errados.
     */
    _getVientoFieldValue: function(value) {
        if (value === 'null' || value === 'NULL'  || value === null) {
            return null;
        } else {
            return value;
        }
    },
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
    fetchDataURL: glb_dataUrl + 'atletasPruebasResultadosController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'atletasPruebasResultadosController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'atletasPruebasResultadosController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'atletasPruebasResultadosController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ],
    /**
     * Caso especial para generar el JSON de un advanced criteria para ser pasada como parte del
     * POST.
     */
    transformRequest: function (dsRequest) {
        var data = this.Super("transformRequest", arguments);

        // En el caso que el viento sea de menos 100 por protocolo se enviara null ya que ese es un numero magico
        // usado para enteder que es nulo.
//        if (dsRequest.operationType == 'add' || dsRequest.operationType == 'update') {
//            if (data['competencias_pruebas_viento'] === '-100') {
//                data['competencias_pruebas_viento'] = null;
//            }
//        }
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
                //console.log(jsonCriteria);
                data._acriteria = jsonCriteria;
            }
        }
        return data;
    }
});