/**
 * Definicion del modelo para los Tipos de competencia
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-30 18:58:10 -0500 (lun, 30 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_competencias",
    showPrompt: true,
    dataFormat: "json",
    fields: [
        {name: "competencias_codigo", title: "Codigo", primaryKey: "true", required: true},
        {name: "competencias_descripcion", title: "Descripcion", required: true,
            validators: [{type: "regexp", expression: glb_RE_onlyValidText}]
        },
        {name: "competencia_tipo_codigo", title: "Tipo", foreignKey:"mdl_competencia_tipo.competencia_tipo_codigo",required: true},
        {name: "paises_codigo", title: "Pais", foreignKey: "mdl_paises.paises_codigo", required: true},
        {name: "ciudades_codigo", title: 'Ciudad', foreignKey: "mdl_ciudades.ciudades_codigo", required: true},
        {name: "categorias_codigo", title: 'Categoria', foreignKey: "mdl_categorias.categorias_codigo", required: true},
        {name: "competencias_fecha_inicio", title: 'Fecha De Inicio', type: 'date', required: true},
        {name: "competencias_fecha_final", title: 'Fecha Final', type: 'date', required: true},
        {name: "competencias_clasificacion", title: 'Clasificacion', valueMap: {"O": 'Outdoor', "I": 'Indoor'}, required: true},
        // Los sguientes son solo para pantalla
        {name: "competencia_tipo_descripcion", title: "Tipo"},
        {name: "paises_descripcion", title: "Pais"},
        {name: "ciudades_descripcion", title: 'Ciudad'},
        {name: "ciudades_altura", type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_competencias._getBooleanFieldValue(v);
            }},
        {name: "categorias_descripcion", title: 'Categoria'},
        {name: "agno", title: 'A&ntilde;o', type: 'integer'}

    ],
    fetchDataURL: glb_dataUrl + 'competenciasController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'competenciasController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'competenciasController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'competenciasController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams", skipRowCount: true},
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