<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador que soporta la obtencion de datos para los records que iran
 * a los graficos.
 * Solo efectua fetch como unica operacion.
 *
 * @author $Author: aranape $
 * @since 17-May-2012
 * @version $Id: recordsGraphDataController.php 337 2014-12-03 06:52:40Z aranape $
 *
 * $Date: 2014-12-03 01:52:40 -0500 (mié, 03 dic 2014) $
 * $Rev: 337 $
 */
class recordsGraphDataController extends app\common\controller\TSLAppDefaultCRUDController {

    public function __construct() {
        parent::__construct();
    }

    /**
     * {@inheritDoc}
     */
    protected function setupData() {

        $this->setupOpts = [
            "validateOptions" => [
                "fetch" => []
            ],
            "paramsList" => [
                "fetch" => []
            ],
            "paramsFixableToNull" => [],
            "paramsFixableToValue" => [],
            "paramToMapId" => ''
        ];
    }

    /**
     * {@inheritDoc}
     */
    protected function getBussinessService() {
        return new RecordsGraphDataBussinessService();
    }

    /**
     *
     * @return string con el nombre base que se usara como response
     * procesor de este controller,
     */
    protected function getUserResponseProcessor() {
        return 'ResponseProcessorRecordsAmcharts';
    }

    /**
     *
     * @return string con el nombre base que se usara como filter
     * procesor de este controller,
     */
    public function getFilterProcessor() {
        return 'ConstraintProcessorAmcharts';
        ;
    }

}
