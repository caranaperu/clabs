/**
 * Clase que prepara la informacion previa a emitir el reporte de resultados
 * de atletas individualmente o comparados, luego de preparar la data
 * llama a una ventana externa que emitira los graficos.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2016-01-24 17:06:40 -0500 (dom, 24 ene 2016) $
 * $Rev: 358 $
 */
isc.defineClass("RecordsHistoricosReportWindow", "Window");
isc.RecordsHistoricosReportWindow.addProperties({
    ID: 'recordsHistoricosReportWindow',
    canDragResize: true,
    showFooter: false,
    autoSize: false,
    autoCenter: true,
    isModal: true,
    autoDraw: false,
    width: '400',
    height: '285',
    title: 'Records - Reporte',
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
                        formReportRecordsHist.focusInItem('records_tipo_codigo');
                        formButtons.getMember(1).setDisabled(true);
                        formReportRecordsHist.clearValues();
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

                        if (formReportRecordsHist.getValue('reporte_tipo') == 'Normal') {
                            if (formReportRecordsHist.getValue('formato_xls') == false) {
                                url += '&reportUnit=/reports/atletismo/rptRecordsStandard';
                            } else {
                                url += '&reportUnit=/reports/atletismo/rptRecordsStandardXLS&output=xls';
                            }
                        } else {
                            if (formReportRecordsHist.getValue('formato_xls') == false) {
                                url += '&reportUnit=/reports/atletismo/rptRecordsStandardHistorico';
                            } else {
                                url += '&reportUnit=/reports/atletismo/rptRecordsStandardHistoricoXLS&output=xls';
                            }
                        }
                        url += '&prm_tipoRecord=' + formReportRecordsHist.getValue('records_tipo_codigo');
                        url += '&prm_categoria=' + formReportRecordsHist.getValue('categorias_codigo');

                        if (formReportRecordsHist.getValue('atletas_sexo') !== undefined && formReportRecordsHist.getValue('atletas_sexo') !== '') {
                            url += '&prm_sexo=' + formReportRecordsHist.getValue('atletas_sexo');
                        } else {
                            url += '&prm_sexo='
                        }
                        if (formReportRecordsHist.getValue('pruebas_tipo_codigo') !== undefined && formReportRecordsHist.getValue('pruebas_tipo_codigo') !== '') {
                            url += '&prm_prueba_tipo=' + formReportRecordsHist.getValue('pruebas_tipo_codigo');
                        } else {
                            url += '&prm_prueba_tipo='
                        }
                        if (formReportRecordsHist.getValue('apppruebas_codigo') !== undefined && formReportRecordsHist.getValue('apppruebas_codigo') !== '') {
                            url += '&prm_prueba=' + formReportRecordsHist.getValue('apppruebas_codigo');
                        } else {
                            url += '&prm_prueba='
                        }
                        url += '&prm_altura=' + formReportRecordsHist.getValue('incluye_altura');

                        // user y password
                        url += '&j_username=' + glb_reportServerUser;
                        url += '&j_password=' + glb_reportServerPsw;


                        if (recordsHistoricosReportWindow._reportWindow == undefined) {
                            recordsHistoricosReportWindow._reportWindow = isc.ReportsRecordsOutputWindow.create({source: url});
                        } else {
                            recordsHistoricosReportWindow._reportWindow.setNewContents(url);
                        }
                        recordsHistoricosReportWindow._reportWindow.show();
                        if (formReportRecordsHist.getValue('formato_xls') == true) {
                            recordsHistoricosReportWindow._reportWindow.hide();
                        }
                    }
                }),
                isc.Button.create({
                    ID: "btnExit" + this.ID,
                    width: '100',
                    autoDraw: false,
                    title: "Salir",
                    click: function () {
                        recordsHistoricosReportWindow.hide();
                    }
                })
            ]
        });

        var formReportRecordsHist = isc.DynamicFormExt.create({
            ID: "formReportRecordsHist",
            padding: 5,
            autoSize: true,
            fields: [
                {name: "reporte_tipo", title: 'Tipo Reporte', valueMap: ["Normal", "Historico"], defaultValue: "Normal", width: 75},
                {name: "records_tipo_codigo", title: 'Tipo Record', editorType: "comboBoxExt", length: 50, width: "200", required: true,
                    valueField: "records_tipo_codigo", displayField: "records_tipo_descripcion",
                    pickListFields: [{name: "records_tipo_codigo", width: '30%'}, {name: "records_tipo_descripcion", width: '80%'}],
                    pickListWidth: 280,
                    optionOperationId: 'fetchJoined',
                    defaultValue: 'NACIONAL',
                    editorProperties: {
                        optionDataSource: mdl_records_tipo,
                        minimumSearchLength: 3,
                        textMatchStyle: 'substring',
                        sortField: "records_tipo_descripcion"
                    }},
                {name: "pruebas_tipo_codigo", title: "Tipo Prueba", editorType: "comboBoxExt", length: 80, width: "180",
                    valueField: "pruebas_tipo_codigo", displayField: "pruebas_tipo_descripcion",
                    pickListFields: [{name: "pruebas_tipo_codigo", width: '20%'}, {name: "pruebas_tipo_descripcion", width: '80%'}],
                    pickListWidth: 260,
                    completeOnTab: true,
                    editorProperties: {
                        optionDataSource: mdl_pruebas_tipo,
                        minimumSearchLength: 3,
                        textMatchStyle: 'substring',
                        sortField: "pruebas_tipo_descripcion"
                    },
                },
                {name: "apppruebas_codigo", title: 'Prueba', editorType: "comboBoxExt", length: 50, width: "200",
                    valueField: "apppruebas_codigo", displayField: "apppruebas_descripcion",
                    pickListFields: [{name: "apppruebas_codigo", width: '30%'}, {name: "apppruebas_descripcion", width: '80%'}],
                    pickListWidth: 280,
                    optionOperationId: 'fetchJoined',
                    editorProperties: {
                        optionDataSource: mdl_apppruebas,
                        minimumSearchLength: 3,
                        textMatchStyle: 'substring',
                        sortField: "apppruebas_descripcion"
                    }},
                {name: "atletas_sexo", title: 'sexo', valueMap: ["", "M", "F"], defaultValue: "", width: 75},
                {name: "categorias_codigo", title: 'Categoria', editorType: "comboBoxExt", length: 50, width: "100",
                    valueField: "categorias_codigo", displayField: "categorias_descripcion",
                    pickListFields: [{name: "categorias_codigo", width: '20%'}, {name: "categorias_descripcion", width: '80%'}],
                    pickListWidth: 240,
                    optionOperationId: 'fetchWithPesos',
                    defaultValue: 'MAY',
                    editorProperties: {
                        optionDataSource: mdl_categorias_pesos,
                    }
                },
                //    {name: "incluye_manuales", title: 'Resultados Manuales', defaultValue: true, type: 'boolean', length: 50},
                {name: "incluye_altura", title: 'Altura', defaultValue: true, type: 'boolean', length: 50},
                {name: "formato_xls", title: 'Para Excel', defaultValue: false, type: 'boolean', length: 50},
            ],
            itemChanged: function () {
                formButtons.getMember(1).setDisabled(!formReportRecordsHist.valuesAreValid(false));
            }
        });


        this.addItem(formReportRecordsHist);
        this.addItem(formButtons);
        formButtons.getMember(1).setDisabled(!formReportRecordsHist.valuesAreValid(false));
    }
});
