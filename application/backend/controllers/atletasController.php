<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador para las operaciones CRUD de los atletas
 *
 *
 * @author  Carlos Arana Reategui <aranape@gmail.com>
 * @version 0.1
 * @package SoftAthletics
 * @copyright 2015-2016 Carlos Arana Reategui.
 * @license GPL
 *
 */
class atletasController extends app\common\controller\TSLAppDefaultCRUDController {

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
                "read" => ["langId" => 'atletas', "validationId" => 'atletas_validation', "validationGroupId" => 'v_atletas', "validationRulesId" => 'getAtletas'],
                "add" => ["langId" => 'atletas', "validationId" => 'atletas_validation', "validationGroupId" => 'v_atletas', "validationRulesId" => 'addAtletas'],
                "del" => ["langId" => 'atletas', "validationId" => 'atletas_validation', "validationGroupId" => 'v_atletas', "validationRulesId" => 'delAtletas'],
                "upd" => ["langId" => 'atletas', "validationId" => 'atletas_validation', "validationGroupId" => 'v_atletas', "validationRulesId" => 'updAtletas']
            ],
            "paramsList" => [
                "fetch" => [],
                "read" => ['atletas_codigo', 'verifyExist'],
                "add" => ['atletas_codigo', 'atletas_ap_paterno', 'atletas_ap_materno', 'atletas_nombres', 'paises_codigo',
                    'atletas_nro_documento', 'atletas_nro_pasaporte', 'atletas_fecha_nacimiento', 'atletas_direccion', 'atletas_telefono_casa',
                    'atletas_telefono_celular', 'atletas_email', 'atletas_sexo', 'atletas_observaciones', 'atletas_talla_ropa_buzo',
                    'atletas_talla_ropa_poloshort', 'atletas_talla_zapatillas', 'atletas_norma_zapatillas', 'atletas_url_foto', 'activo'],
                "del" => ['atletas_codigo', 'versionId'],
                "upd" => ['atletas_codigo', 'atletas_ap_paterno', 'atletas_ap_materno', 'atletas_nombres', 'paises_codigo',
                    'atletas_nro_documento', 'atletas_nro_pasaporte', 'atletas_fecha_nacimiento', 'atletas_direccion', 'atletas_telefono_casa',
                    'atletas_telefono_celular', 'atletas_email', 'atletas_sexo', 'atletas_observaciones', 'atletas_talla_ropa_buzo',
                    'atletas_talla_ropa_poloshort', 'atletas_talla_zapatillas', 'atletas_norma_zapatillas', 'atletas_url_foto', 'versionId', 'activo'],
            ],
            "paramsFixableToNull" => ['atletas_', 'paises_'],
            "paramsFixableToValue" => ["atletas_codigo" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
            "paramToMapId" => 'atletas_codigo'
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new AtletasBussinessService();
    }

}
