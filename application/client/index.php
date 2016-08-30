<html>
<head>
    <meta charset="utf-8">
    <title>CLABS - Administrador</title>
    <SCRIPT>var isomorphicDir = "./isomorphic/";</SCRIPT>
    <SCRIPT SRC=./isomorphic/system/modules-debug/ISC_Core.js></SCRIPT>
    <SCRIPT SRC=./isomorphic/system/modules-debug/ISC_Foundation.js></SCRIPT>
    <SCRIPT SRC=./isomorphic/system/modules-debug/ISC_Containers.js></SCRIPT>
    <SCRIPT SRC=./isomorphic/system/modules-debug/ISC_Grids.js></SCRIPT>
    <SCRIPT SRC=./isomorphic/system/modules-debug/ISC_Forms.js></SCRIPT>
    <SCRIPT SRC=./isomorphic/system/modules-debug/ISC_DataBinding.js></SCRIPT>
    <SCRIPT SRC=./isomorphic/system/modules-debug/ISC_Calendar.js></SCRIPT>

    <SCRIPT SRC=./isomorphic/skins/EnterpriseBlue/load_skin.js></SCRIPT>

    <SCRIPT SRC=./appConfig.js></SCRIPT>
    <SCRIPT SRC=./isomorphic_lib/view/IControlledCanvas.js></SCRIPT>
    <SCRIPT SRC=./isomorphic_lib/controller/DefaultController.js></SCRIPT>
    <SCRIPT SRC=./isomorphic_lib/view/DynamicFormExt.js></SCRIPT>
    <SCRIPT SRC=./isomorphic_lib/view/WindowBasicFormExt.js></SCRIPT>
    <SCRIPT SRC=./isomorphic_lib/view/WindowBasicFormNCExt.js></SCRIPT>
    <SCRIPT SRC=./isomorphic_lib/view/WindowGridListExt.js></SCRIPT>
    <SCRIPT SRC=./isomorphic_lib/view/TabSetExt.js></SCRIPT>
    <SCRIPT SRC=./isomorphic_lib/controls/PickTreeExtItem.js></SCRIPT>
    <SCRIPT SRC=./isomorphic_lib/controls/ComboBoxExtItem.js></SCRIPT>
    <SCRIPT SRC=./isomorphic_lib/controls/SelectExtItem.js></SCRIPT>
    <SCRIPT SRC=./isomorphic_lib/controls/DetailGridContainer.js></SCRIPT>


    <SCRIPT SRC=./app/model/SystemMenuModel.js></SCRIPT>
    <SCRIPT SRC=./view/SystemTreeMenu.js></SCRIPT>

    <SCRIPT SRC=./model/EntidadModel.js></SCRIPT>
    <SCRIPT SRC=./view/entidad/EntidadWindow.js></SCRIPT>

    <SCRIPT SRC=app/model/SistemasModel.js></SCRIPT>
    <SCRIPT SRC=app/model/PerfilModel.js></SCRIPT>
    <SCRIPT SRC=app/model/PerfilDetalleModel.js></SCRIPT>

    <SCRIPT SRC=app/view/PerfilWindow.js></SCRIPT>
    <SCRIPT SRC=app/view/PerfilForm.js></SCRIPT>

    <SCRIPT SRC=./model/UsuarioPerfilModel.js></SCRIPT>

    <SCRIPT SRC=./model/UsuariosModel.js></SCRIPT>
    <SCRIPT SRC=./view/usuarios/UsuariosWindow.js></SCRIPT>
    <SCRIPT SRC=./view/usuarios/UsuariosForm.js></SCRIPT>


    <SCRIPT SRC=./model/UnidadMedidaModel.js></SCRIPT>
    <SCRIPT SRC=./view/unidadmedida/UnidadMedidaWindow.js></SCRIPT>
    <SCRIPT SRC=./view/unidadmedida/UnidadMedidaForm.js></SCRIPT>

    <SCRIPT SRC=./model/UnidadMedidaConversionModel.js></SCRIPT>
    <SCRIPT SRC=./view/unidadmedida_conversion/UnidadMedidaConversionWindow.js></SCRIPT>
    <SCRIPT SRC=./view/unidadmedida_conversion/UnidadMedidaConversionForm.js></SCRIPT>

    <SCRIPT SRC=./model/MonedaModel.js></SCRIPT>
    <SCRIPT SRC=./view/monedas/MonedaWindow.js></SCRIPT>
    <SCRIPT SRC=./view/monedas/MonedaForm.js></SCRIPT>

    <SCRIPT SRC=./model/TipoCambioModel.js></SCRIPT>
    <SCRIPT SRC=./view/tipocambio/TipoCambioWindow.js></SCRIPT>
    <SCRIPT SRC=./view/tipocambio/TipoCambioForm.js></SCRIPT>

    <SCRIPT SRC=./model/TipoInsumoModel.js></SCRIPT>
    <SCRIPT SRC=./view/tinsumo/TipoInsumoWindow.js></SCRIPT>
    <SCRIPT SRC=./view/tinsumo/TipoInsumoForm.js></SCRIPT>

    <SCRIPT SRC=./model/TipoCostosModel.js></SCRIPT>
    <SCRIPT SRC=./view/tcostos/TipoCostosWindow.js></SCRIPT>
    <SCRIPT SRC=./view/tcostos/TipoCostosForm.js></SCRIPT>

    <SCRIPT SRC=./model/InsumoModel.js></SCRIPT>
    <SCRIPT SRC=./view/insumos/InsumoWindow.js></SCRIPT>
    <SCRIPT SRC=./view/insumos/InsumoForm.js></SCRIPT>

    <SCRIPT SRC=./model/ProductoModel.js></SCRIPT>
    <SCRIPT SRC=./model/ProductoDetalleModel.js></SCRIPT>
    <SCRIPT SRC=./view/productos/ProductoWindow.js></SCRIPT>
    <SCRIPT SRC=./view/productos/ProductoForm.js></SCRIPT>




</head>
<body></body>
<SCRIPT>
    isc.VLayout.create({
        width: "100%",
        height: "100%",
        members: [
            isc.ToolStrip.create({
                overflow: "hidden",
                width: "100%",
                autoDraw: false
            }),
            isc.HLayout.create({
                width: "100%",
                height: "100%",
                autoDraw: false,
                members: [
                    isc.SectionStack.create({
                        ID: "sectionStack",
                        align: "left",
                        showResizeBar: true,
                        visibilityMode: "multiple",
                        width: "15%",
                        height: "100%",
                        border: "1px solid blue",
                        autoDraw: false,
                        sections: [
                            {
                                title: "Opciones",
                                expanded: true,
                                canCollapse: true,
                                items: [
                                    isc.SystemTreeMenu.create()
                                ]
                            },
                            {
                                title: "Preferidos",
                                expanded: true,
                                canCollapse: true
                            }
                        ]
                    }),
                    isc.VLayout.create({
                        width: "90%",
                        autoDraw: false,
                        members: [
                            isc.Label.create({
                                contents: "Details",
                                align: "center",
                                overflow: "hidden",
                                height: "70%",
                                border: "1px solid blue",
                                autoDraw: false
                            })
                        ]
                    })
                ]
            })
        ]
    });


</SCRIPT>
</html>