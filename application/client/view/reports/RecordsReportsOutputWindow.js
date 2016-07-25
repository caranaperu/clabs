/**
 * Clase que prepara la ventana para la vista del reporte de records
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2015-02-22 22:10:50 -0500 (dom, 22 feb 2015) $
 * $Rev: 352 $
 */
isc.defineClass("ReportsRecordsOutputWindow", "Window");
isc.ReportsRecordsOutputWindow.addProperties({
    ID: 'reportsRecordsOutputWindow',
    canDragResize: true,
    showFooter: false,
    autoCenter: true,
    isModal: true,
    autoDraw: false,
    width: '900',
    height: '600',
    title: 'Reporte de Records',
    _htmlPane: undefined,
    /**
     * Metodo para cambiar el url que presenta el pane de salida
     * del reporte
     *
     * @param String url , el URL del reporte a presentar
     */
    setNewContents: function (url) {
        this._htmlPane.setContentsURL(url);
    },
    // Inicialiamos los widgets interiores
    initWidget: function () {
        this.Super("initWidget", arguments);
        this._htmlPane = isc.HTMLPane.create({
            //  ID: "reportPane",
            showEdges: false,
            contentsURL: reportsRecordsOutputWindow.source,
            contentsType: "page",
            height: '90%'
        })

        // Botones principales del header
        var formButtons = isc.HStack.create({
            membersMargin: 10,
            height: '5%',
            layoutAlign: "center", padding: 5, autoDraw: false,
            align: 'center',
            members: [isc.Button.create({
                    //ID: "btnExit" + this.ID,
                    width: '100',
                    autoDraw: false,
                    title: "Salir",
                    click: function () {
                        reportsRecordsOutputWindow.hide();
                    }
                })
            ]
        });

        var layout = isc.VLayout.create({
            width: '100%',
            height: '*',
            members: [
                this._htmlPane,
                formButtons
            ]
        });

        this.addItem(layout);
    }
});
