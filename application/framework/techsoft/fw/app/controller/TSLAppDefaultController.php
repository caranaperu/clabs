<?php

namespace app\common\controller;

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador sugerido como default para las aplicaciones.
 * Por default , todos los input parametros que sean pasados por parseParameters
 * seran procesados de tal forma que los 'null' se conviertan en reales NULL.
 *
 * Siempre usaran un unico vie de salida el cual esta preparado para responder a
 * ajax calls.
 *
 * Los reponse y constraint processor seran cargados dinamicamente a partir de los parametros
 * libid (que libreria se esta usando) y filterformat (XML,json,etc)
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: TSLAppDefaultController.php 193 2014-06-23 19:50:39Z aranape $
 * @history ''
 *
 * $Date: 2014-06-23 14:50:39 -0500 (lun, 23 jun 2014) $
 * $Rev: 193 $
 */
class TSLAppDefaultController extends \TSLBaseController implements \TSLISessionController, \TSLIConstrainedController {

    public function __construct() {
        parent::__construct();
        // Dos posibilidades
        // 1: dentro del apppath para adentro
        // 2: a la altura de apppath para abajo
        $this->load->add_package_path(APPPATH.'framework/techsoft/fw/');
        $this->load->add_package_path(APPPATH.'../framework/techsoft/fw/');
    }

    /**
     * Funcion de apoyo para eliminar los parametros
     * que llegan con el valor 'null' en texto ya que
     * sera asumido como texto y no un real NULL en la capa
     * de persistencia , de tal forma que en esos casos se asignara
     * un real NULL al parametro, previo a su proceso posterior.
     *
     * En el caso $beginWith fuera un array entonces se chequeara para
     * cada caso en el arreglo , esto es util cuando los parametros
     * de entrada a chequear no tienen un solo prefijo.
     *
     * @param string o array $beginWith Para los parametros que inician con
     * este valor.
     */
    protected function parseParameters($beginWith) {

        if (is_array($beginWith)) {
            foreach ($beginWith as $str) {
                // Parche de parametros
                foreach ($_POST as $i => $value) {
                    // Comienza con?
                    if (strpos($i, $str, 0) === 0) {
                        $this->fixParameter($i, 'null', NULL);
                    }
                }
            }
        } else {
            // Parche de parametros
            foreach ($_POST as $i => $value) {
                // Comienza con?
                if (strpos($i, $beginWith, 0) === 0) {
                    $this->fixParameter($i, 'null', NULL);
                }
            }
        }
    }

    public function getView() {
        return 'TSLDefaultDataResponseView';
    }

    public function getResponseProcessor() {
        $responseProcessor = \TSLResponseProcessorLoaderHelper::loadResponseProcessor($this->getUserResponseProcessor(), isset($_REQUEST['filterformat']) ? $_REQUEST['filterformat'] : $this->getDefaultFilterType(), isset($_REQUEST['libid']) ? $_REQUEST['libid'] : NULL);
        return $responseProcessor;
    }

    /*     * ************************************************************************
     * De la interace para constrained controller
     */

    public function getDefaultFilterType() {
        return 'json';
    }

    public function getDefaultSorterType() {
        return 'json';
    }

    public function getFilterProcessor() {
        return NULL;
    }

    public function getSorterProcessor() {
        return NULL;
    }

    public function getConstraintProcessor() {
        $constraintProcessor = \TSLConstraintProcessorLoaderHelper::loadConstraintProcessor($this->getFilterProcessor(), isset($_REQUEST['filterformat']) ? $_REQUEST['filterformat'] : $this->getDefaultFilterType(), isset($_REQUEST['libid']) ? $_REQUEST['libid'] : NULL);
        return $constraintProcessor;
    }

    // De la interface de session \TSLISessionController
    //
    //

    /**
     * @inheritDoc
     */
    public function getUserCode() {
        if ($this->session->userdata('usuario_code') !== FALSE) {
            return $this->session->userdata('usuario_code');
        } else {
            return null;
        }
    }

    /**
     * @inheritDoc
     */
    public function getUserId() {
        if ($this->session->userdata('usuario_id') !== FALSE) {
            return $this->session->userdata('usuario_id');
        } else {
            return -1;
        }
    }

    /**
     * @inheritDoc
     */
    public function isLoggedIn() {
        if ($this->session->userdata('isLoggedIn') !== FALSE) {
            return $this->session->userdata('isLoggedIn');
        } else {
            return false;
        }
    }

    /**
     * @inheritDoc
     */
    public function getSessionData($name) {
        return $this->session->userdata($name);
    }

    /**
     * @inheritDoc
     */
    public function setUserCode($userCode) {
        $this->session->set_userdata('usuario_code',$userCode);
    }

    /**
     * @inheritDoc
     */
    public function setUserId($userId) {
        $this->session->set_userdata('usuario_id',$userId);
    }

    /**
     * @inheritDoc
     */
    public function setLoggedIn($isLoggedIn) {
        $this->session->set_userdata('isLoggedIn',$isLoggedIn);
    }

    /**
     * @inheritDoc
     */
    public function setSessionData($name, $data) {
        $this->session->set_userdata($name,$data);
    }

    /**
     * @inheritDoc
     */
    public function unsetSessionData($name) {
        $this->session->unset_userdata($name);
    }


}
