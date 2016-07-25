<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo para definir los resultados de las pruebas de los atletas , esta es una
 * entidad fisica del modelo de datos.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: AtletasResultadosModel.php 197 2014-06-23 19:58:15Z aranape $
 * @history ''
 *
 * $Date: 2014-06-23 14:58:15 -0500 (lun, 23 jun 2014) $
 * $Rev: 197 $
 */
class AtletasResultadosModel extends \app\common\model\TSLAppCommonBaseModel {

    use AtletasResultadosModelTraits;
    protected $competencias_pruebas_id;
    protected $postas_id;

    /**
     * Setea el id unico de competencia / prueba a la que pertenece
     * este resultado.
     *
     * @param integer $competencias_pruebas_id unico de la relacion competencias-pruebas
     */
    public function set_competencias_pruebas_id($competencias_pruebas_id) {
        $this->competencias_pruebas_id = $competencias_pruebas_id;
    }

    /**
     * @return integer retorna el id unico de la relacion competencias-pruebas
     * a la que pertenece este resultado.
     */
    public function get_competencias_pruebas_id() {
        return $this->competencias_pruebas_id;
    }

    /**
     * @return integer retorna el id de la posta en el  caso sea una prueba de este
     *                 tipo de lo contrario sera null.
     */
    public function get_postas_id() {
        return $this->postas_id;
    }

    /**
     * Setea el id unico de de la posta en caso que esta prueba o resultado
     * sea de una posta.
     *
     * @param integer $postas_id id de la posta , puede ser null si la prueba no es posta.
     */
    public function set_postas_id($postas_id) {
        $this->postas_id = $postas_id;
    }

    public function &getPKAsArray() {
        $pk['atletas_resultados_id'] = $this->getId();
        return $pk;
    }

    /**
     * Indica que su pk o id es una secuencia o campo identity
     *
     * @return boolean true
     */
    public function isPKSequenceOrIdentity() {
        return true;
    }

}

?>