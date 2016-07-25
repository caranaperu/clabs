<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de los paises.
 *
 * @author $Author: aranape $
 * @since 17-May-2012
 * @version $Id: competenciaTipoController.php 70 2014-03-09 10:20:51Z aranape $
 *
 * $Date: 2014-03-09 05:20:51 -0500 (dom, 09 mar 2014) $
 * $Rev: 70 $
 */
class competenciaTipoController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'competencia_tipo', "validationId" => 'competencia_tipo_validation', "validationGroupId" => 'v_competencia_tipo', "validationRulesId" => 'getCompetenciaTipo'],
                "add" => ["langId" => 'competencia_tipo', "validationId" => 'competencia_tipo_validation', "validationGroupId" => 'v_competencia_tipo', "validationRulesId" => 'addCompetenciaTipo'],
                "del" => ["langId" => 'competencia_tipo', "validationId" => 'competencia_tipo_validation', "validationGroupId" => 'v_competencia_tipo', "validationRulesId" => 'delCompetenciaTipo'],
                "upd" => ["langId" => 'competencia_tipo', "validationId" => 'competencia_tipo_validation', "validationGroupId" => 'v_competencia_tipo', "validationRulesId" => 'updCompetenciaTipo']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['competencia_tipo_codigo', 'verifyExist'],
                "add" => ['competencia_tipo_codigo', 'competencia_tipo_descripcion', 'activo'],
                "del" => ['competencia_tipo_codigo', 'versionId'],
                "upd" => ['competencia_tipo_codigo', 'competencia_tipo_descripcion', 'versionId', 'activo']],
            "paramsFixableToNull" => ['competencia_tipo_'],
            "paramsFixableToValue" => ["competencia_tipo_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'competencia_tipo_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new CompetenciaTipoBussinessService();
    }
}
