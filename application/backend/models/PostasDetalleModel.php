<?php

    if (!defined('BASEPATH'))
        exit('No direct script access allowed');

    /**
     * Modelo para los detalles de las postas, aqui se define cada atleta
     * que compone una posta.
     *
     * @author    Carlos Arana Reategui <aranape@gmail.com>
     * @version   0.1
     * @package   SoftAthletics
     * @copyright 2015-2016 Carlos Arana Reategui.
     * @license   GPL
     *
     */
    class PostasDetalleModel extends \app\common\model\TSLAppCommonBaseModel {

        protected $postas_detalle_id;
        protected $postas_id;
        protected $atletas_codigo;

        /**
         * Setea el id del detalle de posta
         *
         * @param int $postas_detalle_id id del detalle de posta
         */
        public function set_postas_detalle_id($postas_detalle_id) {
            $this->postas_detalle_id = $postas_detalle_id;
            $this->setId($postas_detalle_id);
        }

        /**
         * Retorna el id del detalle de posta
         *
         * @return int
         */
        public function get_postas_detalle_id() {
            return $this->postas_detalle_id;
        }

        /**
         * EL id de la posta a la cual pertenece esta entrada,
         *
         * @return int retorna el unique id de la posta
         */
        public function get_postas_id() {
            return $this->postas_id;
        }

        /**
         * Setea el id unico de la posta..
         *
         * @param int $postas_id unique id de la posta
         */
        public function set_postas_id($postas_id) {
            $this->postas_id = $postas_id;
        }

        /**
         * Setea el id que identifica al atleta que pertenece a la posta.
         *
         * @param int $atletas_codigo id del atleta.
         */
        public function set_atletas_codigo($atletas_codigo) {
            $this->atletas_codigo = $atletas_codigo;
        }


        /**
         * Retorna id que identifica al atleta que pertenece a la posta.
         *
         * @return int con el id del atleta.
         */
        public function get_atletas_codigo() {
            return $this->atletas_codigo;
        }


        /**
         * @{inheritdoc}
         */
        public function &getPKAsArray() {
            $pk['postas_detalle_id'] = $this->getId();

            return $pk;
        }


        /**
         * Indica que su pk o id es una secuencia o campo identity
         *
         * @return boolean true
         */
        public function isPKSequenceOrIdentity() {
            return TRUE;
        }
    }