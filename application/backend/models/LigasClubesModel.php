<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo para definir las lineaas de relacion que  asocian clubes a ligas
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: LigasClubesModel.php 45 2014-02-18 16:35:30Z aranape $
 * @history ''
 *
 * $Date: 2014-02-18 11:35:30 -0500 (mar, 18 feb 2014) $
 * $Rev: 45 $
 */
class LigasClubesModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $ligasclubes_id;
    protected $ligas_codigo;
    protected $clubes_codigo;
    protected $ligasclubes_desde;
    protected $ligasclubes_hasta;

    /**
     * Setea el id unico de la relacion clubes-ligas
     *
     * @param integer $ligasclubes_id unico de la relacion clubes-ligas
     */
    public function set_ligasclubes_id($ligasclubes_id) {
        $this->ligasclubes_id = $ligasclubes_id;
        $this->setId($ligasclubes_id);
    }

    /**
     * @return integer retorna el id unico de la relacion clubes-ligas
     */
    public function get_ligasclubes_id() {
        return $this->ligasclubes_id;
    }

    /**
     * Setea el codigo de la liga a relacionar
     *
     * @param string $ligas_codigo codigo de la liga
     */
    public function set_ligas_codigo($ligas_codigo) {
        $this->ligas_codigo = $ligas_codigo;
    }

    /**
     *
     * @return string con el codigo de la liga a relacionas
     */
    public function get_ligas_codigo() {
        return $this->ligas_codigo;
    }

    /**
     *
     * @return string con el codigo del club a relacionar con una liga
     */
    public function get_clubes_codigo() {
        return $this->clubes_codigo;
    }

    /**
     * Setea el codigo del club a relacionar con una liga
     *
     * @param string $clubes_codigo
     */
    public function set_clubes_codigo($clubes_codigo) {
        $this->clubes_codigo = $clubes_codigo;
    }

    /**
     *
     * @return string que representa la fecha desde que el club
     * se asocia a la liga. (no es la fecha de ingreso al sistema)
     */
    public function get_ligasclubes_desde() {
        return $this->ligasclubes_desde;
    }

    /**
     * Setea la fecha desde que el club se asocia a la liga.
     * (no es la fecha de ingreso al sistema)
     *
     * @param string $ligasclubes_desde la fecha en string convertible a date.
     */
    public function set_ligasclubes_desde($ligasclubes_desde) {
        $this->ligasclubes_desde = $ligasclubes_desde;
    }

        /**
     *
     * @return string que representa la fecha hasta que el club
     * se asocio a la liga. (no es la fecha de ingreso al sistema)
     */
    public function get_ligasclubes_hasta() {
        return $this->ligasclubes_hasta;
    }

    /**
     * Setea la fecha hasta que el club se asocio a la liga.
     *
     * @param string $ligasclubes_desde la fecha en string convertible a date.
     */
    public function set_ligasclubes_hasta($ligasclubes_hasta) {
        $this->ligasclubes_hasta = $ligasclubes_hasta;
    }

    public function &getPKAsArray() {
        $pk['ligasclubes_id'] = $this->getId();
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