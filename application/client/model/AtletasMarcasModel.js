/**
 * Definicion del modelo los marcas de un atleta
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 04:46:05 -0500 (mar, 24 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_atletasmarcas",
    showPrompt: true,
    dataFormat: "json",
    fields: [
        {name: "atletas_resultados_id"},
        {name: "atletas_codigo", title: 'Atleta', foreignKey: "mdl_atletas.atletas_codigo"},
        {name: "pruebas_codigo", title: "Prueba", foreignKey: "mdl_pruebas.pruebas_codigo"},
        {name: "atletas_resultados_puesto", title: "Puesto", type: 'integer'},
        {name: "atletas_resultados_resultado", title: "Marca"},
        {name: "competencias_pruebas_viento", title: "Viento"},
        {name: "competencias_pruebas_fecha", title: "Fecha", type: 'date'},
        {name: "obs", title: "Obs", type: 'text'},
        {name: "categorias_codigo", title: "Cat."},
        {name: "pruebas_record_hasta", title: "Rank"},
        {name: "lugar", title: "Lugar"},
        {name: "serie", title: "Serie"},
        {name: "origen"},
        {name: "apppruebas_multiple", type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_atletasmarcas._getBooleanFieldValue(v);
            }}

    ],
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
    fetchDataURL: glb_dataUrl + 'atletasPruebasResultadosController?op=fetch&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"}
    ]
});