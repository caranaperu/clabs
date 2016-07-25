/**
 * Definicion del modelo para los paises
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2016-01-24 17:08:20 -0500 (dom, 24 ene 2016) $
 */
isc.RestDataSource.create({
    ID: "mdl_records_tipo",
    dataFormat: "json",
    cacheAllData: true, // Son datos pequeños hay que evitar releer
    fields: [
        {name: "records_tipo_codigo", title: 'Codigo', primaryKey: "true", required: true},
        {name: "records_tipo_descripcion", title: "Descripcion", required: true},
        {name: "records_tipo_abreviatura", title: "Abreviatura", required: true},
        {name: "records_tipo_tipo", title: "Tipo",
            valueMap: {"A": 'Absoluto', "C": 'Competencia'}, required: true},
        {name: "records_tipo_clasificacion", title: "Clasificacion",
            valueMap: {"M": 'Mundial', "O": 'Olimpico', "R": 'Regional', "N": 'Nacional', "T": 'Panamericano o Similares', "X": 'Otros'}, required: true},
        {name: "records_tipo_peso", title: "Peso", type: 'integer',
            validators: [{type: "lengthRange", max: 4}, {type: 'integerRange', min: 0, max: 9999}],
            required: true},
        {name: "records_tipo_protected", type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_records_tipo._getBooleanFieldValue(v);
            }, required: true},
    ],
    fetchDataURL: glb_dataUrl + 'recordsTipoController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'recordsTipoController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'recordsTipoController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'recordsTipoController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
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

    }
});