<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD para definir los valores de validacion para las categorias
 * de atletas , digase mayores , menores , etc , donde se indicara el peso relativo de una
 * con la otra , digamos pesara mas la que su record sea de mayor valor , por ejemplo mayores pesara mas que menores.
 *
 * @author $Author: aranape $
 * @since 17-May-2012
 * @version $Id: appCategoriasController.php 68 2014-03-09 10:19:20Z aranape $
 *
 * $Date: 2014-03-09 05:19:20 -0500 (dom, 09 mar 2014) $
 * $Rev: 68 $
 */
class appCategoriasController extends app\common\controller\TSLAppDefaultCRUDController {

    public function __construct() {
        parent::__construct();
    }

 /**
     * {@inheritDoc}
     */
    protected function setupData() {

        $this->setupOpts = [
            "validateOptions" => [
                "fetch" => [],
                "read" => ["langId" => 'appcategorias', "validationId" => 'appcategorias_validation', "validationGroupId" => 'v_appcategorias', "validationRulesId" => 'getAppCategoria'],
                "add" => ["langId" => 'appcategorias', "validationId" => 'appcategorias_validation', "validationGroupId" => 'v_appcategorias', "validationRulesId" => 'addAppPruebas'],
                "del" => ["langId" => 'appcategorias', "validationId" => 'appcategorias_validation', "validationGroupId" => 'v_appcategorias', "validationRulesId" => 'delAppPruebas'],
                "upd" => ["langId" => 'appcategorias', "validationId" => 'appcategorias_validation', "validationGroupId" => 'v_appcategorias', "validationRulesId" => 'updAppPruebas']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['appcat_codigo', 'verifyExist']],
            "paramsFixableToNull" => ['appcat_'],
            "paramsFixableToValue" => ["appcat_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'appcat_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new AppCategoriasBussinessService();
    }
}
