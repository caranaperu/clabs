/**
 * Clase que prepara la informacion previa a emitir el reporte de resultados
 * de un atleta, luego de preparar la data llama a una ventana externa que emitira el reporte.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2016-01-24 17:06:40 -0500 (dom, 24 ene 2016) $
 * $Rev: 358 $
 */
isc.defineClass("AtletasResultadosReportWindow", "Window");
isc.AtletasResultadosReportWindow.addProperties({
    ID: 'atletasResultadosReportWindow',
    canDragResize: true,
    showFooter: false,
    autoSize: false,
    autoCenter: true,
    isModal: true,
    autoDraw: false,
    width: '400',
    height: '230',
    title: 'Resultados x Atleta - Reporte',
    // Handle a la ventana de reporte
    _reportWindow: undefined,
    // Inicialiamos los widgets interiores
    initWidget: function () {
        this.Super("initWidget", arguments);

        // Botones principales del header
        var formButtons = isc.HStack.create({
            membersMargin: 10,
            height: 24,
            layoutAlign: "center", padding: 5, autoDraw: false,
            align: 'center',
            members: [isc.Button.create({
                    ID: "btndoClear" + this.ID,
                    width: '100',
                    autoDraw: false,
                    title: "Limpiar",
                    click: function () {
                        formReportAtletasResultados.focusInItem('pruebas_tipo_codigo');
                        formButtons.getMember(1).setDisabled(true);
                        formReportAtletasResultados.clearValues();
                    }
                }),
                isc.Button.create({
                    ID: "btnDoGraph" + this.ID,
                    title: 'Ejecutar',
                    width: '100',
                    autoDraw: false,
                    disabled: true,
                    click: function () {
                        // prepara la llamada
                        var url = glb_reportServerUrl + '/flow.html?_flowId=viewReportFlow&standAlone=false&decorate=no&_flowId=viewReportFlow' +
                                '&ParentFolderUri=/reports/atletismo&&viewAsDashboardFrame=false';

                        if (formReportAtletasResultados.getValue('formato_xls') == false) {
                            url += '&reportUnit=/reports/atletismo/rptResultadosAtleta';
                        } else {
                            url += '&reportUnit=/reports/atletismo/rptResultadosAtletasXLS&output=xls';
                        }

                        if (formReportAtletasResultados.getValue('categorias_codigo') !== undefined && formReportRecordsHist.getValue('categorias_codigo') != 'TOD') {
                            url += '&prm_categoria=' + formReportAtletasResultados.getValue('categorias_codigo');
                        } else {
                            url += '&prm_categoria=';
                        }

                        if (formReportAtletasResultados.getValue('apppruebas_codigo') !== undefined && formReportRecordsHist.getValue('apppruebas_codigo') !== '') {
                            url += '&prm_prueba=' + formReportAtletasResultados.getValue('apppruebas_codigo');
                        } else {
                            url += '&prm_prueba=';
                        }
                        url += '&prm_atletas_codigo=' + formReportAtletasResultados.getValue('atletas_codigo');
                        if (formReportAtletasResultados.getValue('ano_desde') !== undefined && formReportRecordsHist.getValue('ano_desde') !== '') {
                            url += '&prm_ano_inicial=' + formReportAtletasResultados.getValue('ano_desde');
                        }
                        if (formReportAtletasResultados.getValue('ano_hasta') !== undefined && formReportRecordsHist.getValue('ano_hasta') !== '') {
                            url += '&prm_ano_final=' + formReportAtletasResultados.getValue('ano_hasta');
                        }
                        // user y password
                        url += '&j_username=' + glb_reportServerUser;
                        url += '&j_password=' + glb_reportServerPsw;


                        if (atletasResultadosReportWindow._reportWindow == undefined) {
                            atletasResultadosReportWindow._reportWindow = isc.ReportsRecordsOutputWindow.create({source: url});
                        } else {
                            atletasResultadosReportWindow._reportWindow.setNewContents(url);
                        }
                        atletasResultadosReportWindow._reportWindow.show();
                        if (formReportAtletasResultados.getValue('formato_xls') == true) {
                            atletasResultadosReportWindow._reportWindow.hide();
                        }
                    }
                }),
                isc.Button.create({
                    ID: "btnExit" + this.ID,
                    width: '100',
                    autoDraw: false,
                    title: "Salir",
                    click: function () {
                        atletasResultadosReportWindow.hide();
                    }
                })
            ]
        });

        var formReportRecordsHist = isc.DynamicFormExt.create({
            ID: "formReportAtletasResultados",
            padding: 5,
            autoSize: true,
            fields: [
                {name: "apppruebas_codigo", title: 'Prueba', editorType: "comboBoxExt", length: 50, width: "200",
                    valueField: "apppruebas_codigo", displayField: "apppruebas_descripcion",
                    pickListFields: [{name: "apppruebas_codigo", width: '30%'}, {name: "apppruebas_descripcion", width: '80%'}],
                    pickListWidth: 280,
                    optionOperationId: 'fetchJoined',
                  //  editorProperties: {
                        optionDataSource: mdl_apppruebas,
                    //    minimumSearchLength: 3,
                        textMatchStyle: 'substring',
                        sortField: "apppruebas_descripcion",
                  //  },
                    changed: function (form, item, value) {
                        // si la prueba es cambiada debe limpiarse los atletas
                        var prueba = item.getSelectedRecord();
                        if (prueba) {
                            formReportAtletasResultados.getItem('atletas_codigo').forceRefresh();
                        }
                        formReportAtletasResultados.getItem('atletas_codigo').clearValue();
                    }
                },
                {name: "categorias_codigo", title: 'Categoria', editorType: "comboBoxExt", length: 50, width: "100",
                    valueField: "categorias_codigo", displayField: "categorias_descripcion",
                    pickListFields: [{name: "categorias_codigo", width: '20%'}, {name: "categorias_descripcion", width: '80%'}],
                    pickListWidth: 240,
                    optionOperationId: 'fetchWithPesos',
                    defaultValue: 'TOD',
                    editorProperties: {
                        optionDataSource: mdl_categorias_pesos,
                    }
                },
                {name: "atletas_codigo", title: 'Atleta', editorType: "comboBoxExt", length: 50, colSpan: '4', width: "*", endRow: true,
                    valueField: "atletas_codigo", displayField: "atletas_nombre_completo",
                    pickListFields: [{name: "atletas_codigo", width: '30%'}, {name: "atletas_nombre_completo", width: '80%'}],
                    pickListWidth: 260,
                    completeOnTab: true,
                    required: true,
                    optionOperationId: 'fetchForListByPrueba',
                    optionDataSource: mdl_atletas,
                    textMatchStyle: 'substring',
                    sortField: "atletas_nombre_completo",
                    /**
                     * Se hace el override ya que este campo requiere que solo obtenga las pruebas
                     * que dependen de la de la prueba y sexo seleccionados en caso se indique prueba
                     */
                    getPickListFilterCriteria: function () {
                        return formReportRecordsHist.getPickListFilterCriteriaForAtletasCodigo(this);
                    }
                },
                {name: "ano_desde", title: 'Desde', type: 'integer', mask: "####", length: 4, width: 60,
                    validators: [
                        {type: "anoMenorCheck",
                            // Valida que el año menor no sea mayor que la final
                            // dado que en este momento se tratan como string normalizamos y comparamos
                            condition: function (item, validator, value) {
                                formReportRecordsHist.clearFieldErrors('ano_hasta', true);
                                var testMenor = parseInt(formReportRecordsHist.getValue('ano_desde'));
                                var testMayor = parseInt(formReportRecordsHist.getValue('ano_hasta'));
                                if (testMenor < 1900 || testMenor > 2050) {
                                    validator.errorMessage = 'El rango valido es de 1900 a 2050';
                                    return false;
                                } else if (testMenor > testMayor) {
                                    validator.errorMessage = 'No puede ser mayor que el Año Hasta';
                                    return false;
                                }
                                return true;
                            }
                        }
                    ]},
                {name: "ano_hasta", title: 'Hasta', type: 'integer', mask: "####", length: 4, width: 60,
                    validators: [
                        {type: "anoMayorCheck",
                            // Valida que el año menor no sea mayor que la final
                            // dado que en este momento se tratan como string normalizamos y comparamos
                            condition: function (item, validator, value) {
                                formReportRecordsHist.clearFieldErrors('ano_desde', true);
                                var testMenor = parseInt(formReportRecordsHist.getValue('ano_desde'));
                                var testMayor = parseInt(formReportRecordsHist.getValue('ano_hasta'));
                                if (testMayor < 1900 || testMayor > 2050) {
                                    validator.errorMessage = 'El rango valido es de 1900 a 2050';
                                    return false;
                                } else if (testMayor < testMenor) {
                                    validator.errorMessage = 'No puede ser menor que el Año Desde';
                                    return false;
                                }
                                return true;
                            }
                        }
                    ]},
                {name: "formato_xls", title: 'Para Excel', defaultValue: false, type: 'boolean', length: 50},
            ],
            itemChanged: function () {
                formButtons.getMember(1).setDisabled(!formReportAtletasResultados.valuesAreValid(false));
            },
            /**
             * Se hace el override ya que este campo requiere que solo obtenga las pruebas
             * que dependen de la de la categoria y el sexo del atleta,el primero proviene
             * de la competencia y el segundo del atleta.
             */
            getPickListFilterCriteriaForAtletasCodigo: function (item) {
                // Recogo primero el filtro si existe uno y luego le agrego
                // la categoria y el sexo.
                var filter = item.Super("getPickListFilterCriteria", arguments);
                if (filter == null) {
                    filter = {};
                }
              //  console.log(formReportAtletasResultados.getValue('apppruebas_codigo'))
                if (formReportAtletasResultados.getValue('apppruebas_codigo') != undefined) {
                    filter = {_constructor: "AdvancedCriteria",
                        operator: "and", criteria: [
                            {fieldName: "pruebas_generica_codigo", operator: "equals", value: formReportAtletasResultados.getValue('apppruebas_codigo')}
                        ]};
                }
              //  console.log(filter)
                return filter;
            },
        });


        this.addItem(formReportAtletasResultados);
        this.addItem(formButtons);
        formButtons.getMember(1).setDisabled(!formReportAtletasResultados.valuesAreValid(false));
    }
});
