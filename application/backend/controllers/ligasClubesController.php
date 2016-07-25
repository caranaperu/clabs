<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD para definir las relacion liga-club.
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class ligasClubesController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'ligasclubes', "validationId" => 'ligasclubes_validation', "validationGroupId" => 'v_ligasclubes', "validationRulesId" => 'getLigasClubes'],
                "add" => ["langId" => 'ligasclubes', "validationId" => 'ligasclubes_validation', "validationGroupId" => 'v_ligasclubes', "validationRulesId" => 'addLigasClubes'],
                "del" => ["langId" => 'ligasclubes', "validationId" => 'ligasclubes_validation', "validationGroupId" => 'v_ligasclubes', "validationRulesId" => 'delLigasClubes'],
                "upd" => ["langId" => 'ligasclubes', "validationId" => 'ligasclubes_validation', "validationGroupId" => 'v_ligasclubes', "validationRulesId" => 'updLigasClubes']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['ligasclubes_id', 'verifyExist'],
                "add" => ['ligas_codigo', 'clubes_codigo', 'ligasclubes_desde', 'ligasclubes_hasta', 'activo'],
                "del" => ['ligasclubes_id', 'versionId'],
                "upd" => ['ligasclubes_id','ligas_codigo', 'clubes_codigo', 'ligasclubes_desde', 'ligasclubes_hasta', 'versionId', 'activo']],
            "paramsFixableToNull" => ['ligasclubes_', 'ligas_', 'clubes_'],
            "paramsFixableToValue" => ["ligasclubes_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'ligasclubes_id'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new LigasClubesBussinessService();
    }
}
