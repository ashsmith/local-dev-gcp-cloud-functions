import chai from 'chai';
import chaiHttp from 'chai-http';
import express from 'express';
import {helloWorld} from '../src/helloWorld';

chai.use(chaiHttp);
chai.should();

const app = express();
app.all('/', helloWorld);

describe('helloWorld function', () => {
  describe('GET /', () => {
    it('should get return hello world', done => {
      chai
        .request(app)
        .get('/')
        .end((err, res) => {
          res.should.have.status(200);
          res.text.should.be.a('string');
          res.text.should.equal('Hello, World!');
          done();
        });
    });
  });
});
