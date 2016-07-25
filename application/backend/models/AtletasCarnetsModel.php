<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir los carnets de campo.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: AtletasCarnetsModel.php 85 2014-03-25 10:12:35Z aranape $
 * @history ''
 *
 * $Date: 2014-03-25 05:12:35 -0500 (mar, 25 mar 2014) $
 * $Rev: 85 $
 */
class AtletasCarnetsModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $atletas_carnets_id;
    protected $atletas_codigo;
    protected $atletas_carnets_numero;
    protected $atletas_carnets_agno;
    protected $atletas_carnets_fecha;

    /**
     * Setea el id unico del carnet , esto es provisto normalmente
     * por la base de datos.
     *
     * @param int $atletas_carnets_id id unico al carnet
     */
    public function set_atletas_carnets_id($atletas_carnets_id) {
        $this->atletas_carnets_id = $atletas_carnets_id;
        $this->setId($atletas_carnets_id);
    }

    /**
     *
     * @return int retorna el id unico al carnet
     */
    public function get_atletas_carnets_id() {
        return $this->atletas_carnets_id;
    }

    /**
     * Indica el año de competencias para el cual es valido el carnet.
     *
     * @return int año de competencia.
     */
    public function get_atletas_carnets_agno() {
        return $this->atletas_carnets_agno;
    }

    /**
     * Setea el año de competencias para el cual es valido el carnet.
     *
     * @param int año de competencia.
     */
    public function set_atletas_carnets_agno($atletas_carnets_agno) {
        $this->atletas_carnets_agno = $atletas_carnets_agno;
    }

    /**
     * Setea el numero de carnet , el cual debe ser unico para cada año.
     *
     * @param string $atletas_carnets_numero numero unico del carnet para el año.
     */
    public function set_atletas_carnets_numero($atletas_carnets_numero) {
        $this->atletas_carnets_numero = $atletas_carnets_numero;
    }

    /**
     *
     * @return string con el numero de carnet , el cual debe ser unico para cada año.
     */
    public function get_atletas_carnets_numero() {
        return $this->atletas_carnets_numero;
    }

    /**
     * Setea el codigo del atleta que adquiere el carnet.
     *
     * @param string $atletas_codigo codigo del atleta que adquiere el carnet.
     */
    public function set_atletas_codigo($atletas_codigo) {
        $this->atletas_codigo = $atletas_codigo;
    }

    /**
     * @return string retorna el codigo del atleta que adquiere el carnet.
     */
    public function get_atletas_codigo() {
        return $this->atletas_codigo;
    }

    /**
     *
     * @return string que representa la fecha de emision
     * del carnet.
     */
    public function get_atletas_carnets_fecha() {
        return $this->atletas_carnets_fecha;
    }

    /**
     *
     * @param string $atletas_carnets_fecha la fecha de emision del carnet.
     */
    public function set_atletas_carnets_fecha($atletas_carnets_fecha) {
        $this->atletas_carnets_fecha = $atletas_carnets_fecha;
    }

    public function &getPKAsArray() {
        $pk['atletas_carnets_id'] = $this->getId();
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