<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo para definir las lineaas de relacion clubes y atletas
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: ClubesAtletasModel.php 20 2014-02-15 05:22:37Z aranape $
 * @history ''
 *
 * $Date: 2014-02-15 00:22:37 -0500 (sáb, 15 feb 2014) $
 * $Rev: 20 $
 */
class ClubesAtletasModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $clubesatletas_id;
    protected $clubes_codigo;
    protected $atletas_codigo;
    protected $clubesatletas_desde;
    protected $clubesatletas_hasta;

    /**
     * Setea el id unico de la relacion clubes-atletas
     *
     * @param integer $clubesatletas_id unico de la relacion clubes-atletas
     */
    public function set_clubesatletas_id($clubesatletas_id) {
        $this->clubesatletas_id = $clubesatletas_id;
        $this->setId($clubesatletas_id);
    }

    /**
     * @return integer retorna el id unico de la relacion clubes-atletas
     */
    public function get_clubesatletas_id() {
        return $this->clubesatletas_id;
    }

    /**
     * Setea el codigo del club a relacionar
     *
     * @param string $clubes_codigo codigo del club
     */
    public function set_clubes_codigo($clubes_codigo) {
        $this->clubes_codigo = $clubes_codigo;
    }

    /**
     *
     * @return string con el codigo del club
     */
    public function get_clubes_codigo() {
        return $this->clubes_codigo;
    }

    /**
     *
     * @return string con el codigo del atleta a relacionar con un club
     */
    public function get_atletas_codigo() {
        return $this->atletas_codigo;
    }

    /**
     * Setea el codigo del atleta a relacionar con un club
     *
     * @param string $atletas_codigo
     */
    public function set_atletas_codigo($atletas_codigo) {
        $this->atletas_codigo = $atletas_codigo;
    }

    /**
     *
     * @return string que representa la fecha desde que el atleta
     * se asocia al club. (no es la fecha de ingreso al sistema)
     */
    public function get_clubesatletas_desde() {
        return $this->clubesatletas_desde;
    }

    /**
     * Setea la fecha desde que el atleta se asocia al club.
     * (no es la fecha de ingreso al sistema)
     *
     * @param string $clubesatletas_desde la fecha en string convertible a date.
     */
    public function set_clubesatletas_desde($clubesatletas_desde) {
        $this->clubesatletas_desde = $clubesatletas_desde;
    }

    /**
     *
     * @return string que representa la fecha hasta la cual el atleta
     * estuvo asociado al club.
     */
    public function get_clubesatletas_hasta() {
        return $this->clubesatletas_hasta;
    }

    /**
     * Setea la fecha hasta la cual el atleta
     * estuvo asociado al club.
     *
     * @param string $ligasclubes_desde la fecha en string convertible a date.
     */
    public function set_clubesatletas_hasta($clubesatletas_hasta) {
        $this->clubesatletas_hasta = $clubesatletas_hasta;
    }

    public function &getPKAsArray() {
        $pk['clubesatletas_id'] = $this->getId();
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