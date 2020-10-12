import type {HttpFunction} from '@google-cloud/functions-framework/build/src/functions';
import {helloWorld} from './helloWorld';

const ROUTES = [
  {
    pathRegex: /^\/helloWorld/,
    function: helloWorld,
  },
];

export const index: HttpFunction = (req, res) => {
  const routes = ROUTES.filter(route => req.path.match(route.pathRegex));
  if (routes.length === 0) {
    throw new Error(
      'Unknown path, have you defined your function in src/index.ts?'
    );
  }

  const [entrypoint] = routes;
  req.path.replace(entrypoint.pathRegex, '');
  return entrypoint.function(req, res);
};

export {helloWorld};
