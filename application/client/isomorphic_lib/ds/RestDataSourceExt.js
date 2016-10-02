/**
 * Interfase que define el API requerido para un data source que requiere transformar
 * su request que contiene un AdvancedCriteria a algo simple para el servidor , asi mismo
 * contiene un metodo default para el procesamiento de campos boolean.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2016-01-24 17:08:51 -0500 (dom, 24 ene 2016) $
 * $Rev: 360 $
 */
isc.defineClass("RestDataSourceExt", isc.RestDataSource);

isc.RestDataSourceExt.addProperties({

    /**
     * Este metodo puede ser sobreescrito por la clase que impelenta.
     * Por default efectua genera un JSON a partir de un advanced criteria para
     * ser pasada como parte de un POST , de una manera practica para ser parseada
     * por el servidor.
     *
     *
     * @return {Object} con la data de un dsRequest.
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
                data._acriteria = jsonCriteria;
            }
        }
        return data;
    },
    /**
     * Normalizador de valores booleanos ya que el backend pude devolver de diversas formas
     * segun la base de datos.
     */
    _getBooleanFieldValue: function(value) {
        if (value !== 't' && value !== 'T' && value !== 'Y' && value !== 'y' && value !== 'TRUE' && value !== 'true' && value !== true) {
            return false;
        } else {
            return true;
        }
    },
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ],
    initWidget: function (parms) {
        this.Super("initWidget", arguments);
    }
});
