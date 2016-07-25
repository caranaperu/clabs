/**
 * Definicion del modelo para los paises
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 04:47:26 -0500 (mar, 24 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_apppruebas",
    dataFormat: "json",
    showPrompt: true,
    //   cacheAllData: true, // Son datos pequeños y en este caso fijos hay que evitar releer
    fields: [
        {
            name: "apppruebas_codigo",
            title: 'Codigo',
            primaryKey: "true",
            required: true
        },
        {
            name: "apppruebas_descripcion",
            title: "Descripcion",
            required: true
        },
        {
            name: "pruebas_clasificacion_codigo",
            title: "Clasificacion",
            foreignKey: 'mdl_pruebas_clasificacion.pruebas_clasificacion_codigo',
            required: true
        },
        {
            name: "apppruebas_marca_menor",
            title: "Marca Menor Valida",
            required: true
        },
        {
            name: "apppruebas_marca_mayor",
            title: "Mayor Mayor Valida",
            required: true
        },
        {
            name: "apppruebas_multiple",
            title: "Combinada?",
            type: 'boolean',
            getFieldValue: function (r, v, f, fn) {
                return mdl_apppruebas._getBooleanFieldValue(v);
            },
            required: true
        },
        {
            name: "apppruebas_verifica_viento",
            title: "Limite de Viento?",
            type: 'boolean',
            getFieldValue: function (r, v, f, fn) {
                return mdl_apppruebas._getBooleanFieldValue(v);
            },
            required: true
        },
        {
            name: "apppruebas_viento_individual",
            title: "Se computa individualmente?",
            type: 'boolean',
            getFieldValue: function (r, v, f, fn) {
                return mdl_apppruebas._getBooleanFieldValue(v);
            },
            required: true
        },
        {
            name: "apppruebas_viento_limite_normal",
            title: "Viento (normal)",
            type: 'float'
        },
        {
            name: "apppruebas_viento_limite_multiple",
            title: "Viento (combinada)",
            type: 'float'
        },
        {
            name: "apppruebas_nro_atletas",
            title: "Nro.Atletas",
            type: 'integer',
            valueMap: [1,
                       4]
        },
        {
            name: "apppruebas_factor_manual",
            title: "Factor De Correcion Manual",
            type: 'float',
            validators: [{
                type: "floatRange",
                min: '0.00',
                max: '0.30'
            }]
        },
        {
            name: "apppruebas_protected",
            type: 'boolean',
            getFieldValue: function (r, v, f, fn) {
                return mdl_apppruebas._getBooleanFieldValue(v);
            },
            required: true
        },
        // Virtuales
        {
            name: "pruebas_clasificacion_descripcion",
            title: "Clasificacion"
        },
        {name: "unidad_medida_codigo"}
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
    fetchDataURL: glb_dataUrl + 'appPruebasController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'appPruebasController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'appPruebasController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'appPruebasController?op=del&libid=SmartClient',
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
    ]
});