<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de las categorias de competicion
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class categoriasController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'categorias', "validationId" => 'categorias_validation', "validationGroupId" => 'v_categorias', "validationRulesId" => 'getCategorias'],
                "add" => ["langId" => 'categorias', "validationId" => 'categorias_validation', "validationGroupId" => 'v_categorias', "validationRulesId" => 'addCategorias'],
                "del" => ["langId" => 'categorias', "validationId" => 'categorias_validation', "validationGroupId" => 'v_categorias', "validationRulesId" => 'delCategorias'],
                "upd" => ["langId" => 'categorias', "validationId" => 'categorias_validation', "validationGroupId" => 'v_categorias', "validationRulesId" => 'updCategorias']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['paises_codigo', 'verifyExist'],
                "add" => ['categorias_codigo', 'categorias_descripcion', 'categorias_edad_inicial', 'categorias_edad_final','categorias_valido_desde','categorias_validacion','activo'],
                "del" => ['categorias_codigo', 'versionId'],
                "upd" => ['categorias_codigo', 'categorias_descripcion', 'categorias_edad_inicial', 'categorias_edad_final','categorias_valido_desde','categorias_validacion','versionId','activo'],
            ],
            "paramsFixableToNull" => ['categorias_'],
            "paramsFixableToValue" => ["categorias_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
           "paramToMapId" => 'categorias_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new CategoriasBussinessService();
    }
}
