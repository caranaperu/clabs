/**
 * Definicion del modelo Para una lista de atletas con datos minimos
 * basicamente para listboxes , comboboxes.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 02:39:31 -0500 (mar, 24 jun 2014) $
 * $Rev: 233 $
 */
isc.RestDataSource.create({
    ID: "mdl_atletas_list",
    dataFormat: "json",
    showPrompt: true,
    fields: [
        {name: "atletas_codigo", primaryKey: "true", title: "Codigo"},
        {name: "atletas_nombre_completo", title: "Apellidos,Nombres"},
        {name: "paises_codigo", title: "Pais"},
        {name: "atletas_sexo", title: "Sexo"},
    ],
    fetchDataURL: glb_dataUrl + 'atletasController?op=fetch&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams", skipRowCount: true}
    ],
    /**
     * Caso especial para generar el JSON de un advanced criteria para ser pasada como parte del
     * POST.
     */
    transformRequest: function(dsRequest) {
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
                //console.log(jsonCriteria);
                data._acriteria = jsonCriteria;
            }
        }
        return data;
    }
});